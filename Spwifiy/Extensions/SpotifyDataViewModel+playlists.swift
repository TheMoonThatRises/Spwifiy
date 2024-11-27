//
//  SpotifyDataViewModel+playlists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

extension SpotifyDataViewModel {
    private func getPersonalizedPlaylists(limit: Int)
    async throws -> [Playlist<PlaylistItemsReference>?] {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        return try await spotifyViewModel.spotifyRequest {
            spotifyViewModel.spotify.categoryPlaylists(SpotifyIDs.madeForYouCategory,
                                                       limit: limit)
            .extendPagesConcurrently(spotifyViewModel.spotify)
            .collectAndSortByOffset()
        }
    }

    public func populatePersonalizedPlaylists() async {
        guard let spotifyViewModel, !isRetrievingPersonalizedPlaylist else {
            return
        }

        isRetrievingPersonalizedPlaylist = true

        var playlists: [Playlist<PlaylistItemsReference>] = (try? await getPersonalizedPlaylists(limit: 25))?
            .compactMap { $0 } ?? []

        Task { @MainActor in
            defer {
                isRetrievingPersonalizedPlaylist = false
            }

            withAnimation(.defaultAnimation) {
                dailyMixes = playlists.filter {
                    $0.name.lowercased().contains("daily mix") ||
                    $0.name.lowercased().contains("discover weekly") ||
                    $0.name.lowercased().contains("release radar")
                }.sorted { $0.name < $1.name }
                playlists.removeAll(where: { dailyMixes.contains($0) })

                repeatRewindMixes = playlists.filter {
                    $0.name.lowercased().contains("repeat") ||
                    $0.name.lowercased().contains("rewind")
                }.sorted { $0.name < $1.name }
                playlists.removeAll(where: { repeatRewindMixes.contains($0) })

                typeMixes = playlists.filter {
                    $0.name.lowercased().contains("mix")
                }.sorted { $0.name < $1.name }
                playlists.removeAll(where: { typeMixes.contains($0) })

                if let displayName = spotifyViewModel.userProfile?.displayName?.lowercased() {
                    blends = playlists.filter {
                        $0.name.lowercased().matches("(\\+ )?\(displayName)( \\+)?")
                    }.sorted { $0.name < $1.name }
                    playlists.removeAll(where: { blends.contains($0) })
                }

                otherPlaylists = playlists
            }
        }
    }
}
