//
//  MainViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class MainViewModel: ObservableObject {

    @Published var currentView: MainViewOptions = .home {
        willSet {
            withAnimation(.defaultAnimation) {
                currentViewAnimated = newValue
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

}
