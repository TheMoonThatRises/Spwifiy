//
//  SpotifyDataViewModel+artists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

extension SpotifyDataViewModel {
    public func populateTopArtists() {
        guard let spotifyViewModel, !isRetrievingTopArtists else {
            return
        }

        isRetrievingTopArtists = true

        spotifyViewModel.spotifyRequest {
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

    public func populateFollowingArtists() {
        guard let spotifyViewModel, !isRetrievingFollowingArtists else {
            return
        }

        isRetrievingFollowingArtists = true
        self.followedArtists = []

        spotifyViewModel.spotifyRequest {
            spotifyViewModel.spotify.currentUserFollowedArtists()
                .extendPages(spotifyViewModel.spotify)
        } receiveValue: { artists in
            Task { @MainActor in
                defer {
                    self.isRetrievingFollowingArtists = false
                }

                withAnimation(.defaultAnimation) {
                    self.followedArtists.append(contentsOf: artists.items)
                }
            }
        }
    }
}
