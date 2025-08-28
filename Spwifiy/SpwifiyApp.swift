//
//  SpwifiyApp.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI
import SwiftData
import AlertToast

@main
struct SpwifiyApp: App {

    public static let redirectURI: String = "spwifiy://"
    public static let service = "io.github.themoonthatrises.spwifiy"
    public static let bundleIdentifier = Bundle.main.bundleIdentifier ?? service

    @StateObject var spotifyViewModel: SpotifyViewModel = SpotifyViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if spotifyViewModel.isAuthorized {
                    MainView(spotifyViewModel: spotifyViewModel)
                } else {
                    LoginView(spotifyViewModel: spotifyViewModel)
                }
            }
            .handlesExternalEvents(preferring: ["{path of URL?}"], allowing: ["*"])
            .onOpenURL { url in
                Task { @MainActor in
                    if url.absoluteString.contains(SpotifyViewModel.loginCallback) {
                        do {
                            spotifyViewModel.isAuthenticating = true

                            try await spotifyViewModel.spotifyRequestAccess(redirectURL: url)
                        } catch {
                            print(error)
                        }

                        spotifyViewModel.isAuthenticating = false
                    }
                }
            }
            .toast(isPresenting: $spotifyViewModel.isAuthenticating) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .frame(minWidth: 950, minHeight: 550)
            .background(.bgMain)
            .environment(\.font, .satoshi)
            .tracking(0.5)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
