//
//  SelectedPlaylistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class SelectedPlaylistViewModel: GenericPlaylistViewModel {

    private let playlist: Playlist<PlaylistItemsReference>

    @Published var playlistDetails: Playlist<PlaylistItems>?

    var didPlaylistChange: Bool {
        playlist.snapshotId != playlistDetails?.snapshotId
    }

    init(spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>) {
        self.playlist = playlist

        super.init(spotifyCache: spotifyCache)

        self.playlistDetails = spotifyCache[playlistId: playlist.id]
        self.tracks = spotifyCache[playlistTrackId: playlist.id] ?? []

        self.calcTotalDuration()
        self.sortGenres()
    }

    @MainActor
    override public func updatePlaylistInfo() async {
        let willUpdatePlaylist = didPlaylistChange || playlistDetails == nil
        let willUpdateTracks = tracks.isEmpty || willUpdatePlaylist
        let willUpdateArtists = artists.isEmpty || willUpdateTracks
        let willUpdateSavedTracks = savedTracks.isEmpty || willUpdateArtists

        guard !isFetchingPlaylist && willUpdateSavedTracks else {
            return
        }

        isFetchingPlaylist = true

        defer {
            isFetchingPlaylist = false
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
                    tracks = trackResults

                    calcTotalDuration()
                }
            }

            if willUpdateArtists {
                let artistResults = sortArtist(
                    artistResults: try await spotifyCache.fetchArtists(artistIds: artistIds)
                )

                withAnimation(.defaultAnimation) {
                    artists = artistResults

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

    private func sortGenres() {
        let totalGenres = artists.compactMap { $0.genres }.flatMap { $0 }

        genreList = Array(
            Array(Set(totalGenres)).sorted { one, two in
                let oneCount = totalGenres.filter { $0 == one }.count
                let twoCount = totalGenres.filter { $0 == two }.count

                return oneCount == twoCount ? one > two : oneCount > twoCount
            }.prefix(4)
        )
    }

}
