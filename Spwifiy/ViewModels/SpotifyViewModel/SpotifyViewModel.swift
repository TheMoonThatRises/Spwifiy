//
//  SpotifyViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI
import KeychainAccess

class SpotifyViewModel: ObservableObject {

    private static let corruptAuthLen: [Int] = [374]

    public enum AuthorizationStatus {
        case none, valid, failed
    }

    public enum AuthenticationMethod: String {
        case transport, `init`
    }

    private var isLoadingUserProfile: Bool = false

    private var spotifyAccessTokenURL: (AuthenticationMethod, String, String, Int, Int, String?, String?) -> String {
        { method, sTotp, cTotp, sTime, cTime, buildVer, buildDate in
            var baseToken = "https://open.spotify.com/get_access_token" +
                            "?reason=\(method)&productType=web_player" +
                            "&totp=\(cTotp)&totpServer=\(sTotp)&totpVer=5" +
                            "&sTime=\(sTime)&cTime=\(cTime)"

            if let buildVer = buildVer, let buildDate = buildDate {
                baseToken += "&buildVer=\(buildVer)&buildDate=\(buildDate)"
            }

            return baseToken
        }
    }

    private static let authScopes: Set<Scope> = Scope.allCases

    @Published var isAuthorized: AuthorizationStatus = .none

    public let spotify: SpotifyAPI<AuthorizationCodeFlowPKCEManager>

    private let keychain: Keychain

    @Published var userProfile: SpotifyUser?

    @Published var isAuthenticating: Bool = false
    private var reauthTask: Task<Void, Never>?

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        self.keychain = Keychain(service: SpwifiyApp.service)

        self.spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(clientId: "")
        )
    }

    public func attemptSpotifyAuthToken(method: AuthenticationMethod) async {
        if isAuthenticating {
            return
        }

        Task { @MainActor in
            isAuthenticating = true
        }

        if let authResponseData = await keychain[data: SpotifyAuthManager.authAccessResponse],
           let authResponse = try? decoder.decode(SpotifyAuthResponse.self, from: authResponseData),
           Date().millisecondsSince1970 < authResponse.accessTokenExpirationTimestampMs - 30 * 1000 {
            Task { @MainActor in
                defer {
                    self.isAuthenticating = false
                }

                authClient(authResponse: authResponse)
            }
        } else if let spDcCookieData = await keychain[data: SpotifyAuthManager.spDcCookieKey],
                  let spTCookieData = await keychain[data: SpotifyAuthManager.spTCookieKey],
                  let spDcCookie = try? decoder.decode(SpotifyAuthCookie.self, from: spDcCookieData).httpCookie,
                  let spTCookie = try? decoder.decode(SpotifyAuthCookie.self, from: spTCookieData).httpCookie {
            APIRequest.shared.setCookies(cookies: [spDcCookie, spTCookie], noCache: true)

            async let (buildVer, buildDate) = SpotifyScraper.shared.getBuildInfo(useCache: true) ?? (nil, nil)

            let cTime = Int(floor(Date().millisecondsSince1970))
            async let sTime = SpotifyOTP.shared.retrieveServerTime() ?? Int(cTime / 1000)

            let cTotp = SpotifyOTP.shared.generateOTP(time: cTime)
            let sTotp = await SpotifyOTP.shared.generateOTP(time: sTime * 1000)

            let authUrl = await spotifyAccessTokenURL(method, sTotp, cTotp, sTime, cTime, buildVer, buildDate)

            APIRequest.shared.request(urlString: authUrl, noCache: true) { data in
                Task { @MainActor in
                    defer {
                        self.isAuthenticating = false
                    }

                    APIRequest.shared.removeCookies(cookies: [spDcCookie, spTCookie], noCache: true)

                    guard let data = data,
                          let authResponse = try? self.decoder.decode(SpotifyAuthResponse.self, from: data),
                          !authResponse.isAnonymous else {
                        self.isAuthorized = .failed

                        return
                    }

                    self.keychain[
                        data: SpotifyAuthManager.authAccessResponse
                    ] = try self.encoder.encode(authResponse)

                    self.authClient(authResponse: authResponse)
                }
            }
        } else {
            Task { @MainActor in
                isAuthenticating = false
                isAuthorized = .failed
            }
        }
    }

    @MainActor
    private func authClient(authResponse: SpotifyAuthResponse) {
        print("auth code len: \(authResponse.accessToken.count)")

        if SpotifyViewModel.corruptAuthLen.contains(authResponse.accessToken.count) {
            print("corrupt auth code len, attempting reauth")

            Task {
                try? keychain.remove(SpotifyAuthManager.authAccessResponse)

                await attemptSpotifyAuthToken(method: .`init`)
            }

            return
        }

        let expirationDate = Date(millisecondsSince1970: authResponse.accessTokenExpirationTimestampMs)

        self.spotify.authorizationManager = AuthorizationCodeFlowPKCEManager(
            clientId: authResponse.clientId,
            accessToken: authResponse.accessToken,
            expirationDate: expirationDate,
            refreshToken: nil,
            scopes: SpotifyViewModel.authScopes
        )

        self.isAuthorized = .valid

        if self.reauthTask == nil {
            self.reauthTask = Task(priority: .background) {
                do {
                    // reauth 7 seconds before token expires
                    try await Task.sleep(for: .seconds(expirationDate.timeIntervalSinceNow - 7.0))

                    await self.attemptSpotifyAuthToken(method: .transport)
                } catch {
                    print("failed to wait for reauth time: \(error)")
                }
            }
        }
    }

    public func logout() {
        var request = URLRequest(url: URL(string: "https://open.spotify.com/logout")!)

        request.setValue("Bearer \(spotify.authorizationManager.accessToken!)", forHTTPHeaderField: "Authorization")

        APIRequest.shared.request(request: request, noCache: true) { _ in
            Task { @MainActor in
                self.removeCookies()

                self.isAuthorized = .failed
            }
        }

        spotify.authorizationManager.deauthorize()
    }

    private func removeCookies() {
        do {
            try keychain.remove(SpotifyAuthManager.spDcCookieKey)
            try keychain.remove(SpotifyAuthManager.spTCookieKey)
            try keychain.remove(SpotifyAuthManager.authAccessResponse)
        } catch {
            print("unable to remove unauthorized manager")
        }
    }

    public func spotifyRequest<T>(accessPoint: () -> AnyPublisher<T, Error>,
                                  sink: ((Subscribers.Completion<any Error>) -> Void)? = nil,
                                  receiveValue: ((T) -> Void)? = nil) {
        CombineHandler.handler(result: accessPoint(), sink: {
            sink?($0)

            if case .failure = $0 {
                Task {
                    try? await self.keychain.remove(SpotifyAuthManager.authAccessResponse)

                    await self.attemptSpotifyAuthToken(method: .`init`)
                }
            }
        }, receiveValue: receiveValue)
    }

    public func spotifyRequest<T>(accessPoint: () -> AnyPublisher<T, Error>,
                                  sink: ((Subscribers.Completion<any Error>) throws -> Void)? = nil,
                                  receiveValue: ((T) throws -> Void)? = nil) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            spotifyRequest(accessPoint: accessPoint) {
                if let sink {
                    do {
                        try sink($0)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }

                if case .failure(let error) = $0 {
                    continuation.resume(throwing: error)
                }
            } receiveValue: {
                do {
                    if let receiveValue {
                        try receiveValue($0)
                    }

                    continuation.resume(returning: $0)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func spotifyRequest<T>(accessPoint: () -> AnyPublisher<[T], Error>,
                                  sink: ((Subscribers.Completion<any Error>) throws -> Void)? = nil,
                                  receiveValue: (([T]) throws -> Void)? = nil) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            spotifyRequest(accessPoint: accessPoint) {
                if let sink {
                    do {
                        try sink($0)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }

                if case .failure(let error) = $0 {
                    continuation.resume(throwing: error)
                }
            } receiveValue: {
                do {
                    if let receiveValue {
                        try receiveValue($0)
                    }

                    continuation.resume(returning: $0)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @MainActor
    func loadUserProfile() async {
        guard !isLoadingUserProfile else {
            return
        }

        isLoadingUserProfile = true

        defer {
            self.isLoadingUserProfile = false
        }

        do {
            self.userProfile = try await spotifyRequest {
                spotify.currentUserProfile()
            }
        } catch {
            print("unable to load spotify profile: \(error)")
        }
    }
}
