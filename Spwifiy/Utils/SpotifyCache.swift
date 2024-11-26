//
//  SpotifyCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI
import Combine

struct CacheResponse<T> {
    let item: T?
    let fresh: Bool
}

class SpotifyCache: ObservableObject {

    var spotifyViewModel: SpotifyViewModel?

    var artistsCache: [String: Artist] = [:]
    var albumCache: [String: Album] = [:]
    var playlistCache: [String: Playlist<PlaylistItems>] = [:]
    var trackCache: [String: Track] = [:]

    public func setSpotifyViewModel(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
    }

    subscript(artistId: String) -> Artist? {
        artistsCache[artistId]
    }

    subscript(albumId: String) -> Album? {
        albumCache[albumId]
    }

    subscript(playlistId: String) -> Playlist<PlaylistItems>? {
        playlistCache[playlistId]
    }

    subscript(trackId: String) -> Track? {
        trackCache[trackId]
    }
}
