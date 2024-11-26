//
//  CacheViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

class CacheViewModel: ObservableObject {

    var spotifyViewModel: SpotifyViewModel

    private var playlistVMCache: [String: SelectedPlaylistViewModel]

    init(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
        self.playlistVMCache = [:]
    }

    public func getPlaylist(playlist: Playlist<PlaylistItemsReference>) -> SelectedPlaylistViewModel? {
        let id = playlist.id

        if !playlistVMCache.keys.contains(id) {
            playlistVMCache[id] = SelectedPlaylistViewModel(spotifyViewModel: spotifyViewModel,
                                                            playlist: playlist)
        }

        return playlistVMCache[id]
    }

}
