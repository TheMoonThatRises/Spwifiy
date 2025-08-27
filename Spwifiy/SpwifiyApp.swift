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
    @StateObject var spotifyDataViewModel: SpotifyDataViewModel = SpotifyDataViewModel()

    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    @StateObject var searchViewModel: SearchViewModel = SearchViewModel()
    @StateObject var settingsViewModel: SettingsViewModel = SettingsViewModel()

    @StateObject var avAudioPlayer: AVAudioPlayer = AVAudioPlayer()

    @StateObject var spotifyCache: SpotifyCache = SpotifyCache()

    var body: some Scene {
        WindowGroup {
            Group {
                if spotifyViewModel.isAuthorized {
                    MainView(spotifyViewModel: spotifyViewModel,
                             spotifyDataViewModel: spotifyDataViewModel,
                             mainViewModel: mainViewModel,
                             searchViewModel: searchViewModel,
                             settingsViewModel: settingsViewModel,
                             spotifyCache: spotifyCache,
                             avAudioPlayer: avAudioPlayer)
                    .onAppear {
                        mainViewModel.currentView = .home
                        mainViewModel.showAuthLoading = false
                    }
                    .onDisappear {
                        avAudioPlayer.removeAllSongs()
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
                            mainViewModel.showAuthLoading = true

                            try await spotifyViewModel.spotifyRequestAccess(redirectURL: url)
                        } catch {
                            mainViewModel.errorMessage = error.localizedDescription
                        }

                        mainViewModel.showAuthLoading = false
                    }
                }
            }
            .toast(isPresenting: $mainViewModel.showAuthLoading) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .toast(isPresenting: $mainViewModel.showErrorMessage) {
                AlertToast(displayMode: .alert, type: .error(.red), title: mainViewModel.errorMessage)
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
//            .task {
//                await YoutubeAPI.shared.retrieveVisitorData()
//            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
