//
//  SpotifyDataViewModel+populateSavedAlbums.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

extension SpotifyDataViewModel {
    public func populateSavedAlbums() async {
        guard let spotifyViewModel, !isRetrievingSavedAlbums else {
            return
        }

        isRetrievingSavedAlbums = true

        do {
            let albums = try await spotifyViewModel.spotifyRequest {
                spotifyViewModel.spotify.currentUserSavedAlbums()
                    .extendPagesConcurrently(spotifyViewModel.spotify)
                    .collectAndSortByOffset()
            }

            Task { @MainActor in
                defer {
                    isRetrievingSavedAlbums = false
                }

                savedAlbums = albums.map { $0.item }
            }
        } catch {
            print("unable to get following albums: \(error)")
        }
    }
}
