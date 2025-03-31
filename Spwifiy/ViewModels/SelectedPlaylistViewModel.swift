//
//  SelectedPlaylistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class SelectedPlaylistViewModel: GenericSongCollectionViewModel {

    private let playlist: Playlist<PlaylistItemsReference>

    @Published var playlistDetails: Playlist<PlaylistItems>?

    var showFlags: Int = CollectionShowFlags.showAlbum

    var didPlaylistChange: Bool {
        playlist.snapshotId != playlistDetails?.snapshotId
    }

    override var playingId: String? {
        playlistDetails?.id
    }

    init(spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>) {
        self.playlist = playlist

        super.init(spotifyCache: spotifyCache)

        self.playlistDetails = spotifyCache[playlistId: playlist.id]
        self.allTracks = spotifyCache[playlistTrackId: playlist.id] ?? []

        self.calcTotalDuration()
        self.sortGenres()
    }

    @MainActor
    override public func updateSongCollectionInfo() async {
        let willUpdatePlaylist = didPlaylistChange || playlistDetails == nil
        let willUpdateTracks = tracks.isEmpty || willUpdatePlaylist
        let willUpdateArtists = artists.isEmpty || willUpdateTracks
//        let willUpdateSavedTracks = savedTracks.isEmpty || willUpdateArtists

        guard !isFetchingSongCollection && willUpdateArtists else {
            return
        }

        isFetchingSongCollection = true

        defer {
            isFetchingSongCollection = false
        }

        do {
            if willUpdatePlaylist {
                let playlistResult = try await spotifyCache.fetchPlaylist(playlistId: playlist.id)

                withAnimation(.defaultAnimation) {
                    playlistDetails = playlistResult
                }
            }

            if willUpdateTracks {
                let trackResults = try await spotifyCache.fetchPlaylistTracks(playlistId: playlist.id)

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

                    genreList = artists.compactMap { $0.genres }.flatMap { $0 }

                    sortGenres()
                }
            }

//            if willUpdateSavedTracks {
//                let savedTracksResult = try await spotifyCache
//                    .fetchSavedTracksContain(trackIds: tracks.map { $0.id ?? "" })
//
//                withAnimation(.defaultAnimation) {
//                    savedTracks = savedTracksResult
//                }
//            }
        } catch {
            print("unable to refresh playlist details: \(error)")
        }
    }

}
