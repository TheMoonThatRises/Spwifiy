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
            $0.spotify.artist(SpotifyIdentifier(id: artistId, idCategory: .artist))
        }
    }

    public func fetchArtists(artistIds: [String]) async throws -> [Artist] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let ids = artistIds.map { SpotifyIdentifier(id: $0, idCategory: .artist) }

        return try await withThrowingTaskGroup(of: [Artist].self) { taskGroup in
            for idsChunk in ids.splitInSubArrays(into: ids.count % 50) {
                taskGroup.addTask {
                    let result = try await spotifyViewModel.spotifyRequest {
                        spotifyViewModel.spotify.artists(idsChunk)
                    }.compactMap { $0 }

                    result.forEach { artist in
                        guard let id = artist.id else {
                            return
                        }

                        self.artistsCache[id] = artist
                    }

                    return result
                }
            }

            return try await taskGroup.reduce(into: [Artist]()) { partialResult, artist in
                partialResult.append(contentsOf: artist)
            }
        }
    }

    public func fetchAlbum(albumId: String) async throws -> Album {
        try await fetchItem(cache: &albumCache, id: albumId) {
            $0.spotify.album(SpotifyIdentifier(id: albumId, idCategory: .album))
        }
    }

    public func fetchPlaylist(playlistId: String) async throws -> Playlist<PlaylistItems> {
        try await fetchItem(cache: &playlistCache, id: playlistId) {
            $0.spotify.playlist(SpotifyIdentifier(id: playlistId, idCategory: .playlist))
        }
    }

    public func fetchPlaylistTracks(playlistId: String) async throws -> [Track] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let tracks = try await spotifyViewModel.spotifyRequest {
            spotifyViewModel.spotify.playlistTracks(SpotifyIdentifier(id: playlistId, idCategory: .playlist))
                .extendPagesConcurrently(spotifyViewModel.spotify)
                .collectAndSortByOffset()
        }.compactMap { $0.item }

        playlistTrackCache[playlistId] = tracks

        return tracks
    }

}
