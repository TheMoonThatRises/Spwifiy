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

    @StateObject var avAudioPlayer: AVAudioPlayer = AVAudioPlayer()

    @StateObject var spotifyCache: SpotifyCache = SpotifyCache()

    var body: some Scene {
        WindowGroup {
            Group {
                switch mainViewModel.authStatus {
                case .success:
                    MainView(spotifyViewModel: spotifyViewModel,
                             spotifyDataViewModel: spotifyDataViewModel,
                             mainViewModel: mainViewModel,
                             spotifyCache: spotifyCache,
                             avAudioPlayer: avAudioPlayer)
                        .onAppear {
                            mainViewModel.currentView = .home
                        }
                        .onDisappear {
                            avAudioPlayer.removeAllSongs()
                        }
                case .inProcess, .failed:
                    LoginView(authStatus: $mainViewModel.authStatus)
                case .cookieSet:
                    Text("attempting authorization")
                        .font(.satoshiBlack(24))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task(priority: .utility) {
                            await spotifyViewModel.attemptSpotifyAuthToken()
                        }
                }
            }
            .onChange(of: spotifyViewModel.isAuthorized) { newValue in
                mainViewModel.authStatus = [.valid, .none].contains(newValue) ? .success : .failed
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
