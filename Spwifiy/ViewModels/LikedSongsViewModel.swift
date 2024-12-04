//
//  LikedSongsViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class LikedSongsViewModel: GenericPlaylistViewModel {

    public enum DisplayType {
        case list, grid
    }

    @Published var displayType: DisplayType = .list

    override init(spotifyCache: SpotifyCache) {
        super.init(spotifyCache: spotifyCache)

        self.allTracks = spotifyCache.getSavedTracks()
    }

    @MainActor
    override public func updatePlaylistInfo() async {
        guard !isFetchingPlaylist else {
            return
        }

        isFetchingPlaylist = true

        defer {
            isFetchingPlaylist = false
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
