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

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self.spotifyCache = spotifyCache

        self.artist = artist
        self.topTracks = spotifyCache[artistTopTracksId: artist.id ?? ""] ?? []

        if !self.topTracks.isEmpty {
            Task { @MainActor in
                await getBackgroundArt()
            }
        }
    }

    @MainActor
    public func updateArtistDetails() async {
        let willUpdateTopTracks = topTracks.isEmpty

        guard !isFetchingArtistDetails && willUpdateTopTracks else {
            return
        }

        do {
            if willUpdateTopTracks, let id = artist.id {
                topTracks = try await spotifyCache.fetchArtistTopTracks(artistId: id)

                await getBackgroundArt()
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

}
