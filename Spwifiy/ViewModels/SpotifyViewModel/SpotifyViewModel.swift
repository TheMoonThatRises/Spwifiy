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

    public static let spotifyClientIdKey: String = "spotify_client_id"

    private static let authScopes: Set<Scope> = Scope.allCases

    public private(set) var spotify: SpotifyAPI<AuthorizationCodeFlowPKCEManager>
    public let extendedSpotifyAPI: ExtendedSpotifiyAPI

    private var clientId: String
    private let codeVerifier: String
    private let codeChallenge: String
    private let state: String
    public var authorizationURL: URL?

    @Published var isAuthorized: Bool = false

    @Published var userProfile: SpotifyUser?

    private var isLoadingUserProfile: Bool = false

    @Published var isAuthenticating: Bool = false

    internal let keychain: Keychain

    internal let decoder = JSONDecoder()
    internal let encoder = JSONEncoder()

    init() {
        self.keychain = Keychain(service: SpwifiyApp.service)
        self.clientId = self.keychain[string: SpotifyViewModel.spotifyClientIdKey] ?? ""

        self.spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(clientId: self.clientId)
        )
        self.extendedSpotifyAPI = ExtendedSpotifiyAPI()

        self.isAuthorized = self.spotify.authorizationManager.isAuthorized()

        self.codeVerifier = String.randomURLSafe(length: 128)
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: self.codeVerifier)

        self.state = String.randomURLSafe(length: 128)

        self.updateClientId(newClientId: self.clientId)
        self.extendedSpotifyAPI.setSpotifyViewModel(spotifyViewModel: self)

        if let authData = self.keychain[data: SpotifyViewModel.authorizationManagerKey],
           let pckeAuthManager = try? JSONDecoder()
            .decode(AuthorizationCodeFlowPKCEManager.self, from: authData) {
            self.spotify.authorizationManager = pckeAuthManager
        }

        if self.spotify.authorizationManager.refreshToken != nil {
            self.spotifyRequest {
                self.spotify.authorizationManager.refreshTokens(onlyIfExpired: false)
            } sink: { completion in
                do {
                    try self.authorizeCallback(completion: completion)
                } catch {
                    print(error)

                    Task { @MainActor in
                        self.isAuthorized = false
                    }
                }
            }
        }
    }

    public func spotifyRequest<T>(accessPoint: () -> AnyPublisher<T, Error>,
                                  sink: ((Subscribers.Completion<any Error>) -> Void)? = nil,
                                  receiveValue: ((T) -> Void)? = nil) {
        CombineHandler.handler(publisher: accessPoint(), sink: {
            sink?($0)

            if case .failure = $0 {
                self.logout()
            }
        }, receiveValue: receiveValue)
    }

    public func spotifyRequest<T>(accessPoint: () -> AnyPublisher<T, Error>,
                                  sink: ((Subscribers.Completion<any Error>) throws -> Void)? = nil,
                                  receiveValue: ((T) throws -> Void)? = nil) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            spotifyRequest(accessPoint: accessPoint) {
                if case .failure(let error) = $0 {
                    continuation.resume(throwing: error)
                } else if let sink {
                    do {
                        try sink($0)
                    } catch {
                        continuation.resume(throwing: error)
                    }
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
                if case .failure(let error) = $0 {
                    continuation.resume(throwing: error)
                } else if let sink {
                    do {
                        try sink($0)
                    } catch {
                        continuation.resume(throwing: error)
                    }
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

    public func spotifyRequestAccess(redirectURL: URL) async throws {
        try await spotifyRequest {
            spotify.authorizationManager.requestAccessAndRefreshTokens(
                redirectURIWithQuery: redirectURL,
                codeVerifier: codeVerifier,
                state: state
            )
        } sink: { result in
            try self.authorizeCallback(completion: result)
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

    public func updateClientId(newClientId: String) {
        keychain[string: SpotifyViewModel.spotifyClientIdKey] = newClientId
        clientId = newClientId

        spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(clientId: self.clientId)
        )

        authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: SpwifiyApp.redirectURI + SpotifyViewModel.loginCallback)!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: SpotifyViewModel.authScopes
        )

        CombineHandler.clearCancellables()

        CombineHandler.handler(
            passthrough: self.spotify.authorizationManagerDidChange,
            receiveValue: self.authorizationManagerDidChange
        )

        CombineHandler.handler(
            passthrough: self.spotify.authorizationManagerDidDeauthorize,
            receiveValue: self.authorizationManagerDidDeauthorize
        )
    }

    public func getClientId() -> String {
        clientId
    }

}
