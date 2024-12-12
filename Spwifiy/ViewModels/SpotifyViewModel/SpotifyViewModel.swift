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

    public enum AuthorizationStatus {
        case none, valid, failed
    }

    private var isLoadingUserProfile: Bool = false

    private var spotifyAccessTokenURL: String {
        "https://open.spotify.com/get_access_token?reason=transport&productType=web_player"
    }

    private static let authScopes: Set<Scope> = [
        .playlistReadPrivate,
        .playlistReadCollaborative,
        .userFollowRead,
        .userLibraryRead,
        .userReadEmail,
        .userReadPrivate,
        .userReadRecentlyPlayed,
        .userTopRead
    ]

    @Published var isAuthorized: AuthorizationStatus = .none

    public let spotify: SpotifyAPI<AuthorizationCodeFlowPKCEManager>

    private let keychain: Keychain

    @Published var userProfile: SpotifyUser?

    @Published var isAuthenticating: Bool = false
    private var reauthTask: Task<Void, Never>?

    init() {
        self.keychain = Keychain(service: SpwifiyApp.service)

        self.spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(clientId: "")
        )
    }

    public func attemptSpotifyAuthToken() async {
        let decoder = JSONDecoder()

        if let spDcCookieData = await keychain[data: SpotifyAuthManager.spDcCookieKey],
           let spTCookieData = await keychain[data: SpotifyAuthManager.spTCookieKey],
           let spDcCookie = try? decoder.decode(SpotifyAuthCookie.self, from: spDcCookieData).httpCookie,
           let spTCookie = try? decoder.decode(SpotifyAuthCookie.self, from: spTCookieData).httpCookie {
            Task { @MainActor in
                isAuthenticating = true
            }

            APIRequest.shared.setCookies(cookies: [spDcCookie, spTCookie], noCache: true)

            APIRequest.shared.request(url: URL(string: spotifyAccessTokenURL)!, noCache: true) { data in
                Task { @MainActor in
                    defer {
                        self.isAuthenticating = false
                    }

                    APIRequest.shared.removeCookies(cookies: [spDcCookie, spTCookie], noCache: true)

                    guard let data = data,
                          let authResponse = try? decoder.decode(SpotifyAuthResponse.self, from: data) else {
                        self.isAuthorized = .failed

                        return
                    }

                    if authResponse.isAnonymous {
                        self.isAuthorized = .failed

                        return
                    }

                    self.spotify.authorizationManager = AuthorizationCodeFlowPKCEManager(
                        clientId: authResponse.clientId,
                        accessToken: authResponse.accessToken,
                        expirationDate: Date(millisecondsSince1970: authResponse.accessTokenExpirationTimestampMs),
                        refreshToken: nil,
                        scopes: SpotifyViewModel.authScopes
                    )

                    self.isAuthorized = .valid

                    if self.reauthTask == nil {
                        self.reauthTask = Task(priority: .background) {
                            do {
                                let date = Date(millisecondsSince1970: authResponse.accessTokenExpirationTimestampMs)
                                // reauth 7 seconds before token expires
                                try await Task.sleep(
                                    for: .seconds(date.timeIntervalSinceNow - 7.0)
                                )

                                await self.attemptSpotifyAuthToken()
                            } catch {
                                print("failed to wait for reauth time: \(error)")
                            }
                        }
                    }
                }
            }
        } else {
            Task { @MainActor in
                self.isAuthorized = .failed
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
    }

    private func removeCookies() {
        do {
            try keychain.remove(SpotifyAuthManager.spDcCookieKey)
            try keychain.remove(SpotifyAuthManager.spTCookieKey)
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
                    await self.attemptSpotifyAuthToken()
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
