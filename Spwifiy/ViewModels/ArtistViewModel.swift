//
//  ArtistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class ArtistViewModel: ObservableObject {

    var spotifyCache: SpotifyCache

    private var isFetchingArtistDetails: Bool = false

    @Published var artist: Artist
    @Published var topTracks: [Track] = []

    @Published var backgroundImageURL: URL?
    @Published var monthlyListeners: Int?

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self.spotifyCache = spotifyCache

        self.artist = artist
        self.topTracks = spotifyCache[artistTopTracksId: artist.id ?? ""] ?? []

        Task { @MainActor in
            if !self.topTracks.isEmpty {
                await getBackgroundArt()
            }

            self.monthlyListeners = await SpotifyScraper.shared.getArtistMonthlyListeners(artistId: artist.id ?? "")
        }
    }

    @MainActor
    public func updateArtistDetails() async {
        let willUpdateTopTracks = topTracks.isEmpty
        let willUpdateMonthlyListeners = monthlyListeners == nil

        guard !isFetchingArtistDetails &&
                (
                    willUpdateTopTracks ||
                    willUpdateMonthlyListeners
                ) else {
            return
        }

        do {
            if let id = artist.id {
                if willUpdateTopTracks {
                    topTracks = try await spotifyCache.fetchArtistTopTracks(artistId: id)

                    await getBackgroundArt()
                }

                if willUpdateMonthlyListeners {
                    await getMonthlyListeners(artistId: id)
                }
            }
        } catch {
            print("unable to refresh artist details: \(error)")
        }
    }

    @MainActor
    private func getBackgroundArt() async {
        let imageURLString = await YoutubeMusicAPI.shared.getBackgroundArt(
            artistName: self.artist.name,
            topSong: self.topTracks.first?.name
        )

        if let imageURLString = imageURLString,
           let url = URL(string: imageURLString) {
            withAnimation(.easeInOut) {
                backgroundImageURL = url
            }
        }
    }

    @MainActor
    private func getMonthlyListeners(artistId: String) async {
        let listeners = await SpotifyScraper.shared.getArtistMonthlyListeners(artistId: artistId)

        withAnimation(.easeInOut) {
            monthlyListeners = listeners
        }
    }

}
