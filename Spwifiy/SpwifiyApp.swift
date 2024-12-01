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

    @StateObject var spotifyViewModel: SpotifyViewModel = SpotifyViewModel()
    @StateObject var spotifyDataViewModel: SpotifyDataViewModel = SpotifyDataViewModel()
    @StateObject var mainViewModel: MainViewModel = MainViewModel()

    @StateObject var spotifyCache: SpotifyCache = SpotifyCache()

    @State var showAuthLoading: Bool = false
    @State var showErrorMessage: Bool = false

    @State var errorMessage: String = "" {
        didSet {
            showErrorMessage = !errorMessage.isEmpty
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if spotifyViewModel.isAuthorized {
                    MainView(spotifyViewModel: spotifyViewModel,
                             spotifyDataViewModel: spotifyDataViewModel,
                             mainViewModel: mainViewModel,
                             spotifyCache: spotifyCache)
                        .onAppear {
                            showAuthLoading = false
                        }
                } else {
                    LoginView(spotifyViewModel: spotifyViewModel)
                }
            }
            .handlesExternalEvents(preferring: ["{path of URL?}"], allowing: ["*"])
            .onOpenURL { url in
                Task { @MainActor in
                    if url.absoluteString.contains(SpotifyViewModel.loginCallback) {
                        do {
                            showAuthLoading = true

                            try await spotifyViewModel.spotifyRequestAccess(redirectURL: url)
                        } catch {
                            errorMessage = error.localizedDescription
                        }

                        showAuthLoading = false
                    }
                }
            }
            .toast(isPresenting: $showAuthLoading) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .toast(isPresenting: $showErrorMessage) {
                AlertToast(displayMode: .alert, type: .error(.red), title: errorMessage)
            }
            .frame(minWidth: 950, minHeight: 550)
            .background(.bgMain)
            .environment(\.font, .satoshi)
            .tracking(0.5)
            .task {
                if spotifyDataViewModel.spotifyViewModel == nil {
                    spotifyDataViewModel.setSpotifyViewModel(spotifyViewModel: spotifyViewModel)
                }

                if spotifyCache.spotifyViewModel == nil {
                    spotifyCache.setSpotifyViewModel(spotifyViewModel: spotifyViewModel)
                }
            }
        }
    }
}
