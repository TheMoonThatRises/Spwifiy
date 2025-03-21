//
//  LikedSongsViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class LikedSongsViewModel: GenericSongCollectionViewModel {

    @Published var displayType: DisplayType = .list

    override init(spotifyCache: SpotifyCache) {
        super.init(spotifyCache: spotifyCache)

        self.allTracks = spotifyCache.getSavedTracks()
    }

    @MainActor
    override public func updateSongCollectionInfo() async {
        guard !isFetchingSongCollection else {
            return
        }

        isFetchingSongCollection = true

        defer {
            isFetchingSongCollection = false
        }

        do {
            let savedTracks = try await spotifyCache.fetchSavedTracks()

            withAnimation(.defaultAnimation) {
                allTracks = savedTracks
            }
        } catch {
            print("unable to refresh liked songs: \(error)")
        }
    }

}
