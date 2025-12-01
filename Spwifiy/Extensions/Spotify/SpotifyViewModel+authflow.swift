//
//  SpotifyViewModel+authflow.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 8/29/25.
//

import Foundation
import Combine
import SpotifyWebAPI

extension SpotifyViewModel {

    public static let loginCallback = "spotify-login-callback"
    internal static let authorizationManagerKey = "authorizationManager"

    private var spotifyAccessTokenURL: (String, String) -> String {
        { cTotp, totpVer in
            "https://open.spotify.com/api/token" +
            "?reason=transport&productType=web_player" +
            "&totp=\(cTotp)&totpServer=\(cTotp)&totpVer=\(totpVer)"
        }
    }

    internal func authorizeCallback(completion: Subscribers.Completion<any Error>) throws {
        switch completion {
        case .finished:
            print("user successfully authorized")
        case .failure(let error):
            if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                print("the user denied the authorization request")
                throw SpwifiyErrors.authAccessDenied
            } else {
                print("couldn't authorize application: \(error)")
                throw SpwifiyErrors.unknownError(error.localizedDescription)
            }
        }
    }

    private func fetchCachedAuthResponse() async -> SpotifyAuthResponse? {
        if let authResponseData = await keychain[data: SpotifyAuthManager.authAccessResponse],
           let authResponse = try? decoder.decode(SpotifyAuthResponse.self, from: authResponseData),
           Date().millisecondsSince1970 < Double(authResponse.accessTokenExpirationTimestampMs) - 30 * 1000 {
            return authResponse
        } else {
            return nil
        }
    }

    private func fetchSpotifyAuthResponse(spDcCookie: HTTPCookie) async throws -> SpotifyAuthResponse? {
        let cTime = Int(floor(Date().millisecondsSince1970 / 1000))
        async let serverTime = SpotifyOTP.retrieveServerTime() ?? cTime

        async let (secret, totpVer) = try SpotifyOTP.generateSecret()
        let generator = try await TOTPGenerator(secret: secret)

        let totp = await generator?.generateOTP(Double(serverTime)) ?? ""

        var request = URLRequest(url: URL(string: try await spotifyAccessTokenURL(totp, totpVer))!)
        request.setValue("https://open.spotify.com", forHTTPHeaderField: "Referer")
        request.setValue("application/json", forHTTPHeaderField: "Accept-Type")
        request.setValue("WebPlayer", forHTTPHeaderField: "App-Platform")
        request.setValue("sp_dc=\(spDcCookie.value)", forHTTPHeaderField: "Cookie")

        return try await withCheckedThrowingContinuation { continuation in
            APIRequest.shared.request(request: request, noCache: true) { data in
                guard let data = data,
                      let authResponse = try? self.decoder.decode(SpotifyAuthResponse.self, from: data),
                      !authResponse.isAnonymous else {
                    return continuation.resume(returning: nil)
                }

                Task { @MainActor in
                    self.keychain[
                        data: SpotifyAuthManager.authAccessResponse
                    ] = try? self.encoder.encode(authResponse)

                    continuation.resume(returning: authResponse)
                }
            }
        }
    }

    public func extendedSpotifyAuth() async -> Bool {
        let cacheAuthResponse = await fetchCachedAuthResponse()
        var authResponse: SpotifyAuthResponse?

        if cacheAuthResponse == nil,
           let spDcCookieData = await keychain[data: SpotifyAuthManager.spDcCookieKey],
           let spDcCookie = try? decoder.decode(SpotifyAuthCookie.self, from: spDcCookieData).httpCookie {
            authResponse = try? await fetchSpotifyAuthResponse(spDcCookie: spDcCookie)
        }

        return (cacheAuthResponse ?? authResponse) != nil
    }

    private func removeCookies() {
        do {
            try keychain.remove(SpotifyAuthManager.spDcCookieKey)
            try keychain.remove(SpotifyAuthManager.authAccessResponse)
        } catch {
            print("failed to remove cookies: \(error)")
        }
    }

    public func extendedSpotifyLogout() {
        var request = URLRequest(url: URL(string: "https://open.spotify.com/api/logout")!)

        if let accessToken = spotify.authorizationManager.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        APIRequest.shared.request(request: request, noCache: true) { _ in
            Task { @MainActor in
                self.removeCookies()
            }
        }

    }

    public func logout() {
        extendedSpotifyLogout()
        spotify.authorizationManager.deauthorize()
    }

}
