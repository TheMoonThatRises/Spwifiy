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
    @Published var tracks: [Track] = []

    @Published var genreList: [String] = []

    @Published var dominantColor: Color = .fgPrimary

    var linearGradient: LinearGradient {
        let hsb = dominantColor.toHSB()

        let reColor = Color(hue: hsb.hue,
                            saturation: hsb.saturation,
                            brightness: 0.5)

        return LinearGradient(
            gradient: Gradient(colors: [reColor.opacity(0.8), .bgMain]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @Published var totalDuration: HumanFormat?

    @Published var didSelectSearch: Bool = false
    @Published var searchText: String = ""

    var didPlaylistChange: Bool {
        playlist.snapshotId != playlistDetails?.snapshotId
    }

    init(spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>) {
        self.spotifyCache = spotifyCache
        self.playlist = playlist
        self.playlistDetails = spotifyCache[playlistId: playlist.id]

        self.populateTracks(tracks: spotifyCache[playlistTrackId: playlist.id] ?? [])

        self.calcTotalDuration()
        self.updateArtists()

        self.populateArtists(
            artists: self.sortArtist(artistResults: spotifyCache.getArtists(artistIds: self.artistIds))
        )
    }

    @MainActor
    public func updatePlaylistInfo() async {
        let willUpdatePlaylist = didPlaylistChange || playlistDetails == nil
        let willUpdateTracks = tracks.isEmpty || willUpdatePlaylist
        let willUpdateArtists = artists.isEmpty || willUpdateTracks

        guard !isFetchingPlaylistDetails && willUpdateArtists else {
            return
        }

        isFetchingPlaylistDetails = true

        defer {
            self.isFetchingPlaylistDetails = false
        }

        do {
            if willUpdatePlaylist {
                let playlistResult = try await spotifyCache.fetchPlaylist(playlistId: playlist.id)

                withAnimation(.defaultAnimation) {
                    playlistDetails = playlistResult

                    calcTotalDuration()
                }
            }

            if willUpdateTracks {
                let trackResults = try await spotifyCache.fetchPlaylistTracks(playlistId: playlist.id)

                updateArtists(tracks: trackResults)

                withAnimation(.defaultAnimation) {
                    populateTracks(tracks: trackResults)
                }
            }

            if willUpdateArtists {
                let artistResults = sortArtist(artistResults: try await spotifyCache.fetchArtists(artistIds: artistIds))

                withAnimation(.defaultAnimation) {
                    populateArtists(artists: artistResults)
                }
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
            .humanReadable
    }

    private func updateArtists(tracks: [Track]? = nil) {
        let allIds = (
            tracks ?? self.tracks
        ).compactMap { $0.artists?.compactMap { $0.id } }.flatMap { $0 }

        artistIds = Array(Set(allIds))
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

    private func sortArtist(artistResults: [Artist]) -> [Artist] {
        artistResults.sorted { one, two in
            let oneCount = tracks.filter { (($0.artists?.filter { $0.id == one.id }.count ?? 0) > 0) }.count
            let twoCount = tracks.filter { ($0.artists?.filter { $0.id == two.id }.count ?? 0) > 0 }.count

            return oneCount == twoCount ? one.name > two.name : oneCount > twoCount
        }
    }

    private func populateTracks(tracks: [Track]) {
        let max = artists.count / 10 > 100 ? 100 : artists.count / 10

        self.tracks = Array(tracks.prefix(max))

        Task {
            try await Task.sleep(for: .seconds(0.01))

            Task { @MainActor in
                self.tracks.append(contentsOf: tracks.suffix(tracks.count - max))
            }
        }
    }

    private func populateArtists(artists: [Artist]) {
        let max = artists.count / 4 > 5 ? 5 : artists.count / 4

        self.artists = Array(artists.prefix(max))

        Task {
            try await Task.sleep(for: .seconds(0.01))

            Task { @MainActor in
                self.artists.append(contentsOf: artists.suffix(artists.count - max))
            }
        }
    }
}
