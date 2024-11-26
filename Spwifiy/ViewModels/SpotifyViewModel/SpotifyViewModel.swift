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

    private var isLoadingUserProfile: Bool = false

    private static let authorizationManagerKey = "authorizationManager"

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

    @Published var isAuthorized: Bool = false
    @Published var useURLAuth: Bool = false

    private let clientId: String

    private let codeVerifier: String
    private let codeChallenge: String
    private let state: String

    public let spotify: SpotifyAPI<AuthorizationCodeFlowPKCEManager>

    public let authorizationURL: URL

    private var cancellables: Set<AnyCancellable> = []

    private let keychain: Keychain

    @Published var userProfile: SpotifyUser?

    init() {
        self.clientId = Bundle.main.infoDictionary?["SpotifyClientId"] as? String ?? ""

        self.keychain = Keychain(service: SpwifiyApp.service)

        self.spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(clientId: clientId)
        )

        self.isAuthorized = self.spotify.authorizationManager.isAuthorized()

        self.codeVerifier = String.randomURLSafe(length: 128)
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: self.codeVerifier)

        self.state = String.randomURLSafe(length: 128)

        self.authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: SpwifiyApp.redirectURI + "login-callback")!,
            codeChallenge: self.codeChallenge,
            state: self.state,
            scopes: SpotifyViewModel.authScopes
        )!

        self.spotify.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: self.authorizationManagerDidChange)
            .store(in: &cancellables)

        self.spotify.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: self.authorizationManagerDidDeauthorize)
            .store(in: &cancellables)

        if let authData = self.keychain[data: SpotifyViewModel.authorizationManagerKey],
           let pckeAuthManager = try? JSONDecoder()
                .decode(AuthorizationCodeFlowPKCEManager.self, from: authData) {
            self.spotify.authorizationManager = pckeAuthManager
        }

        if self.spotify.authorizationManager.refreshToken != nil {
            self.spotify.authorizationManager.refreshTokens(onlyIfExpired: false)
                .sink { completion in
                    do {
                        try self.authorizeCallback(completion: completion)
                    } catch {
                        print(error)

                        Task { @MainActor in
                            self.isAuthorized = false
                            self.useURLAuth = true
                        }
                    }
                }
                .store(in: &cancellables)
        } else {
            self.useURLAuth = true
        }
    }

    private func authorizeCallback(completion: Subscribers.Completion<any Error>) throws {
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

    private func authorizationManagerDidChange() {
        isAuthorized = spotify.authorizationManager.isAuthorized()

        do {
            let authManagerData = try JSONEncoder().encode(spotify.authorizationManager)

            keychain[data: SpotifyViewModel.authorizationManagerKey] = authManagerData
        } catch {
            print("unable to store auth manager state")
        }
    }

    private func authorizationManagerDidDeauthorize() {
        isAuthorized = false

        do {
            try keychain.remove(SpotifyViewModel.authorizationManagerKey)
        } catch {
            print("unable to remove unauthorized manager")
        }
    }

    func spotifyRequestAccess(redirectURL: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            spotify.authorizationManager.requestAccessAndRefreshTokens(
                redirectURIWithQuery: redirectURL,
                codeVerifier: codeVerifier,
                state: state
            )
            .sink { completion in
                do {
                    try self.authorizeCallback(completion: completion)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            .store(in: &cancellables)
        }
    }

    func loadUserProfile() {
        guard !isLoadingUserProfile else {
            return
        }

        isLoadingUserProfile = true

        spotify.currentUserProfile()
            .sink { _ in

            } receiveValue: { user in
                Task { @MainActor in
                    defer {
                        self.isLoadingUserProfile = false
                    }

                    self.userProfile = user
                }
            }
            .store(in: &cancellables)
    }
}
