//
//  SpotifyCache+requests.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import Foundation
import Combine
import SpotifyWebAPI

extension SpotifyCache {

    private func fetchItem<T>(cache: inout [String: T],
                              id: String,
                              accessPoint: (SpotifyViewModel) -> AnyPublisher<T, any Error>) async throws -> T {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let result = try await spotifyViewModel.spotifyRequest {
            accessPoint(spotifyViewModel)
        }

        cache[id] = result

        return result
    }

    public func fetchArtist(artistId: String) async throws -> Artist {
        try await fetchItem(cache: &artistsCache, id: artistId) {
            $0.spotify.artist("spotify:artist:\(artistId)")
        }
    }

    public func fetchAlbum(albumId: String) async throws -> Album {
        try await fetchItem(cache: &albumCache, id: albumId) {
            $0.spotify.album("spotify:album:\(albumId)")
        }
    }

    public func fetchPlaylist(playlistId: String) async throws -> Playlist<PlaylistItems> {
        try await fetchItem(cache: &playlistCache, id: playlistId) {
            $0.spotify.playlist("spotify:playlist:\(playlistId)")
        }
    }

    public func fetchTrack(trackId: String) async throws -> Track {
        try await fetchItem(cache: &trackCache, id: trackId) {
            $0.spotify.track("spotify:track:\(trackId)")
        }
    }

}
