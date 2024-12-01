//
//  SpotifyDataViewModel+artists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

extension SpotifyDataViewModel {
    public func populateTopArtists() async {
        guard let spotifyViewModel, !isRetrievingTopArtists else {
            return
        }

        isRetrievingTopArtists = true

        _ = try? await spotifyViewModel.spotifyRequest {
            spotifyViewModel.spotify.currentUserTopArtists(limit: 10)
        } receiveValue: { artists in
            Task { @MainActor in
                defer {
                    self.isRetrievingTopArtists = false
                }

                withAnimation(.defaultAnimation) {
                    self.topArtists = artists.items
                }
            }
        }
    }
}
