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

    @ObservedObject var spotifyViewModel = SpotifyViewModel()

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
                    MainView()
                        .environmentObject(spotifyViewModel)
                        .environmentObject(HomeViewModel(spotifyViewModel: spotifyViewModel))
                        .environmentObject(MainViewModel())
                        .onAppear {
                            showAuthLoading = false
                        }
                } else {
                    LoginView()
                        .environmentObject(spotifyViewModel)
                }
            }
            .handlesExternalEvents(preferring: ["{path of URL?}"], allowing: ["*"])
            .onOpenURL { url in
                Task { @MainActor in
                    do {
                        showAuthLoading = true

                        try await spotifyViewModel.spotifyRequestAccess(redirectURL: url)
                    } catch {
                        errorMessage = error.localizedDescription
                    }

                    showAuthLoading = false
                }
            }
            .toast(isPresenting: $showAuthLoading) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .toast(isPresenting: $showErrorMessage) {
                AlertToast(displayMode: .alert, type: .error(.red), title: errorMessage)
            }
            .frame(minWidth: 950, minHeight: 500)
            .background(.bgMain)
            .environment(\.font, .satoshi)
        }
    }
}
