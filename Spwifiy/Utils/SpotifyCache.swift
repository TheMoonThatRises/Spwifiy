//
//  SpotifyCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

struct CacheResponse<T> {
    let item: T?
    let fresh: Bool
}

class SpotifyCache: ObservableObject {

    var spotifyViewModel: SpotifyViewModel?

    var artistsCache: [String: Artist] = [:]
    var albumCache: [String: Album] = [:]
    var playlistCache: [String: Playlist<PlaylistItems>] = [:]
    var playlistTrackCache: [String: [Track]] = [:]

    var savedTracksCache: [Track] = []

    var savedTracksContainsCache: [String: Bool] = [:]

    subscript(artistId id: String) -> Artist? {
        artistsCache[id]
    }

    subscript(albumId id: String) -> Album? {
        albumCache[id]
    }

    subscript(playlistId id: String) -> Playlist<PlaylistItems>? {
        playlistCache[id]
    }

    subscript(playlistTrackId id: String) -> [Track]? {
        playlistTrackCache[id]
    }

    subscript(isSavedTrack id: String) -> Bool? {
        savedTracksContainsCache[id]
    }

    public func getArtists(artistIds: [String]) -> [Artist] {
        artistIds.compactMap { self[artistId: $0] }
    }

    public func getSavedTracks() -> [Track] {
        savedTracksCache
    }

    public func getSavedTrackContains(trackIds: [String]) -> [Bool] {
        trackIds.map { savedTracksContainsCache[$0] ?? false }
    }

    public func setSpotifyViewModel(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
    }
}
