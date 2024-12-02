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

    var artistsCache = ThreadSafeDictionary<String, Artist>()
    var artistTopTracksCache = ThreadSafeDictionary<String, [Track]>()
    var artistAlbumsCache = ThreadSafeDictionary<String, [Album]>()

    var albumCache = ThreadSafeDictionary<String, Album>()
    var albumTracksCache = ThreadSafeDictionary<String, [Track]>()

    var playlistCache = ThreadSafeDictionary<String, Playlist<PlaylistItems>>()
    var playlistTrackCache = ThreadSafeDictionary<String, [Track]>()

    var savedTracksCache: [Track] = []
    var savedTracksContainsCache = ThreadSafeDictionary<String, Bool>()

    subscript(artistId id: String) -> Artist? {
        artistsCache[id]
    }

    subscript(artistTopTracksId id: String) -> [Track]? {
        artistTopTracksCache[id]
    }

    subscript(artistAlbumsId id: String) -> [Album]? {
        artistAlbumsCache[id]
    }

    subscript(albumId id: String) -> Album? {
        albumCache[id]
    }

    subscript(albumTracksId id: String) -> [Track]? {
        albumTracksCache[id]
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

    public func getAllAlbumTracks(albumIds: [String]) -> [String: [Track]] {
        albumTracksCache.filter { albumIds.contains($0.0) }
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
