//
//  GenericPlaylistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class GenericPlaylistViewModel: ObservableObject {

    let spotifyCache: SpotifyCache

    var isFetchingPlaylist: Bool = false

    var artistIds: [String] = [] {
        didSet {
            artists = sortArtist(artistResults: spotifyCache.getArtists(artistIds: artistIds))
        }
    }

    @Published var artists: [Artist] = []
    @Published var tracks: [Track] = [] {
        didSet {
            updateArtists()
        }
    }
    @Published var savedTracks: [Bool] = []

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

    @Published var searchText: String = ""

    init(spotifyCache: SpotifyCache) {
        self.spotifyCache = spotifyCache
    }

    @MainActor
    public func updatePlaylistInfo() async {
        preconditionFailure("This method must be overridden")
    }

    func calcTotalDuration() {
        totalDuration = tracks
            .map { $0.durationMS ?? 0 }
            .reduce(0, +)
            .humanReadable
    }

    func updateArtists() {
        let allIds = (
            tracks
        ).compactMap { $0.artists?.compactMap { $0.id } }.flatMap { $0 }

        artistIds = Array(Set(allIds))
    }

    func sortArtist(artistResults: [Artist]) -> [Artist] {
        let trackArtist = tracks.compactMap { $0.artists }.flatMap { $0 }.compactMap { $0.id }
        let artistCount = trackArtist.reduce(into: [:]) { counts, word in
            counts[word, default: 0] += 1
        }

        return artistResults.sorted { one, two in
            let oneCount = artistCount[one.id ?? ""] ?? 0
            let twoCount = artistCount[two.id ?? ""] ?? 0

            return oneCount == twoCount ? one.name > two.name : oneCount > twoCount
        }
    }

}
