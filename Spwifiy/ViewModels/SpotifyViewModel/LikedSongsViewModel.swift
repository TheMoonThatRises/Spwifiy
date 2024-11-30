//
//  LikedSongsViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class LikedSongsViewModel: ObservableObject {

    private let spotifyCache: SpotifyCache

    private var isFetchingLikedSongs: Bool = false

    @Published var displayType: DisplayType = .list

    @Published var tracks: [Track] = []

    @Published var searchText: String = ""

    init(spotifyCache: SpotifyCache) {
        self.spotifyCache = spotifyCache

        self.tracks = spotifyCache.getSavedTracks()
    }

    @MainActor
    public func updateLikedSongs() async {
        guard !isFetchingLikedSongs else {
            return
        }

        isFetchingLikedSongs = true

        defer {
            isFetchingLikedSongs = false
        }

        do {
            let savedTracks = try await spotifyCache.fetchSavedTracks()

            withAnimation(.defaultAnimation) {
                tracks = savedTracks
            }
        } catch {
            print("unable to refresh liked songs: \(error)")
        }
    }

}
