//
//  SelectedAlbumViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

class SelectedAlbumViewModel: GenericSongCollectionViewModel {

    private var albumId: String?

    @Published var album: Album?

    init(spotifyCache: SpotifyCache, albumId: String?) {
        self.albumId = albumId
        self.album = spotifyCache[albumId: albumId ?? ""]

        super.init(spotifyCache: spotifyCache)

        self.allTracks = spotifyCache[albumTracksId: albumId ?? ""] ?? []
        self.artists = self.album?.artists ?? []

        if let genres = self.album?.genres {
            self.genreList = genres

            self.sortGenres()
        }
    }

    @MainActor
    override public func updateSongCollectionInfo() async {
        let willUpdateAlbum = album == nil
        let willUpdateTracks = tracks.isEmpty || willUpdateAlbum
        let willUpdateArtists = artists.isEmpty || willUpdateTracks
//        let willUpdateSavedTracks = savedTracks.isEmpty || willUpdateArtists

        guard !isFetchingSongCollection && willUpdateArtists else {
            return
        }

        isFetchingSongCollection = true

        defer {
            isFetchingSongCollection = false
        }

        guard let albumId = albumId else {
            print("album id is nil")
            return
        }

        do {
            if willUpdateAlbum {
                album = try await spotifyCache.fetchAlbum(albumId: albumId)

                if let genres = album?.genres {
                    withAnimation(.defaultAnimation) {
                        genreList = genres

                        sortGenres()
                    }
                }
            }

            if willUpdateTracks {
                let trackResults = try await spotifyCache.fetchAlbumTracks(albumId: albumId)

                withAnimation(.defaultAnimation) {
                    allTracks = trackResults

                    calcTotalDuration()
                }
            }

            if willUpdateArtists {
                let artistResults = sortArtist(
                    artistResults: try await spotifyCache.fetchArtists(artistIds: artistIds)
                )

                withAnimation(.defaultAnimation) {
                    artists = artistResults
                }
            }
        } catch {
            print("unable to refresh album details: \(error)")
        }
    }

}
