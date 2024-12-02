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

    private func fetchItem<T>(cache: inout ThreadSafeDictionary<String, T>,
                              id: String,
                              cacheFirst: Bool = false,
                              accessPoint: (SpotifyViewModel) -> AnyPublisher<T, any Error>) async throws -> T {
        if cacheFirst, let item = cache[id] {
            return item
        }

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
        try await fetchItem(cache: &artistsCache, id: artistId, cacheFirst: true) {
            $0.spotify.artist(SpotifyIdentifier(id: artistId, idCategory: .artist))
        }
    }

    public func fetchArtists(artistIds: [String]) async throws -> [Artist] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let alreadyCachedIds = artistIds.filter { artistsCache[$0] != nil }
        let ids = artistIds
            .filter { !alreadyCachedIds.contains($0) }
            .map { SpotifyIdentifier(id: $0, idCategory: .artist) }

        var result = try await withThrowingTaskGroup(of: [Artist].self) { taskGroup in
            for idsChunk in ids.splitInSubArrays(into: ids.count % 100) {
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

        result.append(contentsOf: alreadyCachedIds.compactMap { artistsCache[$0] })

        return result
    }

    public func fetchArtistTopTracks(artistId: String) async throws -> [Track] {
        try await fetchItem(cache: &artistTopTracksCache, id: artistId, cacheFirst: true) {
            $0.spotify.artistTopTracks(
                SpotifyIdentifier(id: artistId, idCategory: .artist),
                country: "from_token")
        }
    }

    public func fetchArtistAlbum(artistId: String) async throws -> [Album] {
        try await fetchItem(cache: &artistAlbumsCache, id: artistId) {
            $0.spotify.artistAlbums(SpotifyIdentifier(id: artistId, idCategory: .artist))
                .extendPagesConcurrently($0.spotify)
                .collectAndSortByOffset()
        }
    }

    public func fetchAlbum(albumId: String) async throws -> Album {
        try await fetchItem(cache: &albumCache, id: albumId) {
            $0.spotify.album(SpotifyIdentifier(id: albumId, idCategory: .album))
        }
    }

    public func fetchAlbumTracks(albumId: String) async throws -> [Track] {
        try await fetchItem(cache: &albumTracksCache, id: albumId, cacheFirst: true) {
            $0.spotify.albumTracks(SpotifyIdentifier(id: albumId, idCategory: .album))
                .extendPagesConcurrently($0.spotify)
                .collectAndSortByOffset()
        }
    }

    public func fetchAllAlbumTracks(albumIds: [String]) async throws -> [String: [Track]] {
        try await withThrowingTaskGroup(of: (String, [Track]).self) { taskGroup in
            for id in albumIds {
                taskGroup.addTask {
                    let result = try await self.fetchAlbumTracks(albumId: id)

                    self.albumTracksCache[id] = result

                    return (id, result)
                }
            }

            let result = try await taskGroup.reduce(into: [String: [Track]]()) { partialResult, result in
                partialResult[result.0] = result.1
            }

            var returnArray: [String: [Track]] = [:]

            albumIds.forEach { id in
                returnArray[id] = result[id]
            }

            return returnArray
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

    public func fetchSavedTracks() async throws -> [Track] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let savedTracks = try await spotifyViewModel.spotifyRequest {
            spotifyViewModel.spotify.currentUserSavedTracks()
                .extendPagesConcurrently(spotifyViewModel.spotify)
                .collectAndSortByOffset()
        }.compactMap { $0.item }

        savedTracksCache = savedTracks

        return savedTracks
    }

    public func fetchSavedTracksContain(trackIds: [String]) async throws -> [Bool] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        let ids = trackIds.map { SpotifyIdentifier(id: $0, idCategory: .track) }

        return try await withThrowingTaskGroup(of: [Bool].self) { taskGroup in
            for idsChunk in ids.splitInSubArrays(into: ids.count % 100) {
                taskGroup.addTask {
                    let result = try await spotifyViewModel.spotifyRequest {
                        spotifyViewModel.spotify.currentUserSavedTracksContains(idsChunk)
                    }.compactMap { $0 }

                    zip(idsChunk, result).forEach { id, doesContain in
                        self.savedTracksContainsCache[id.id] = doesContain
                    }

                    return result
                }
            }

            return try await taskGroup.reduce(into: [Bool]()) { partialResult, doesContain in
                partialResult.append(contentsOf: doesContain)
            }
        }
    }

}
