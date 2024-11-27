//
//  SelectedPlaylistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI

class SelectedPlaylistViewModel: ObservableObject {

    private let spotifyCache: SpotifyCache
    private let playlist: Playlist<PlaylistItemsReference>

    private var isFetchingPlaylistDetails: Bool = false

    private var artistIds: [String] = []

    @Published var playlistDetails: Playlist<PlaylistItems>?
    @Published var artists: [Artist] = [] {
        didSet {
            sortGenres()
        }
    }

    @Published var genreList: [String] = []

    @Published var dominantColor: Color = .fgPrimary

    @Published var totalDuration: HumanFormat?

    @Published var didSelectSearch: Bool = false
    @Published var searchText: String = ""

    init(spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>) {
        self.spotifyCache = spotifyCache
        self.playlist = playlist
        self.playlistDetails = spotifyCache[playlistId: playlist.id]

        self.calcTotalDuration()
        self.updateArtists()

        self.artists = spotifyCache.getArtists(artistIds: self.artistIds)
    }

    @MainActor
    public func updatePlaylistInfo() async {
        guard !isFetchingPlaylistDetails else {
            return
        }

        isFetchingPlaylistDetails = true

        defer {
            self.isFetchingPlaylistDetails = false
        }

        do {
            let playlistResult = try await spotifyCache.fetchPlaylist(playlistId: playlist.id)

            updateArtists(playlistDetails: playlistResult)

            withAnimation(.defaultAnimation) {
                playlistDetails = playlistResult

                calcTotalDuration()
            }

            let artistResults = try await spotifyCache.fetchArtists(artistIds: artistIds)

            withAnimation(.defaultAnimation) {
                artists = artistResults
            }
        } catch {
            print("unable to refresh playlist details: \(error)")
        }
    }

    private func calcTotalDuration() {
        totalDuration = playlistDetails?
            .items
            .items
            .map { $0.item?.durationMS ?? 0 }
            .reduce(0, +)
            .humanRedable
    }

    private func updateArtists(playlistDetails: Playlist<PlaylistItems>? = nil) {
        artistIds = (
            playlistDetails ?? self.playlistDetails
        )?.items.items.compactMap {
            if case let .track(value) = $0.item {
                return value.artists?.compactMap { $0.id }
            } else {
                return nil
            }
        }.flatMap { $0 } ?? []
    }

    private func sortGenres() {
        let totalGenres = artists.compactMap { $0.genres }.flatMap { $0 }

        genreList = Array(
            Array(Set(totalGenres)).sorted { one, two in
                totalGenres.filter { $0 == one }.count > totalGenres.filter { $0 == two }.count
            }.prefix(5)
        )
    }
}
