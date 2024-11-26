//
//  SpotifyDataViewModel+artists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import Foundation
import SpotifyWebAPI

extension SpotifyDataViewModel {
    public func populateTopArtists() async {
        guard let spotifyViewModel, !isRetrievingTopArtists else {
            return
        }

        isRetrievingTopArtists = true

        let cancellable = spotifyViewModel.spotify.currentUserTopArtists(limit: 10)
            .sink { _ in

            } receiveValue: { artists in
                Task { @MainActor in
                    defer {
                        self.isRetrievingTopArtists = false
                    }

                    self.topArtists = artists.items
                }
            }

        Task { @MainActor in
            cancellable
                .store(in: &cancellables)
        }
    }
}
