//
//  MainViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class MainViewModel: ObservableObject {

    @AppStorage("settings.view.showqueueview") var showQueueView: Bool = false
    @AppStorage("settings.view.queueviewwidth") var queueViewWidth: Double = 300

    @Published var authStatus: SpotifyAuthManager.AuthStatus = .cookieSet

    @Published var currentView: MainViewOptions = .home {
        willSet {
            Task { @MainActor in
                withAnimation(.defaultAnimation) {
                    currentViewAnimated = newValue
                }
            }
        }
    }
    @Published var currentViewAnimated: MainViewOptions = .home

    @Published var selectedArtist: Artist? {
        didSet {
            currentView = .selectedArtist
        }
    }
    @Published var selectedPlaylist: Playlist<PlaylistItemsReference>? {
        didSet {
            currentView = .selectedPlaylist
        }
    }
    @Published var selectedAlbum: Album? {
        didSet {
            currentView = .selectedAlbum
        }
    }

    @Published var playingTrack: Track?

    @Published var showLogoutSheet: Bool = false

    @Published var searchText: String = ""

}
