//
//  CacheViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

class CacheViewModel: ObservableObject {

    var spotifyViewModel: SpotifyViewModel?

    private var playlistVMCache: [String: SelectedPlaylistViewModel] = [:]

    public func setSpotifyViewModel(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
    }

    public func getPlaylist(playlist: Playlist<PlaylistItemsReference>) -> SelectedPlaylistViewModel? {
        guard let spotifyViewModel else {
            return nil
        }

        let id = playlist.id

        if !playlistVMCache.keys.contains(id) {
            playlistVMCache[id] = SelectedPlaylistViewModel(spotifyViewModel: spotifyViewModel,
                                                            playlist: playlist)
        }

        return playlistVMCache[id]
    }

}
