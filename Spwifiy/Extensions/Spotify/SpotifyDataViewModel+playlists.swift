//
//  SpotifyDataViewModel+playlists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import SpotifyWebAPI

extension SpotifyDataViewModel {
    public func populatePersonalizedPlaylists() async {
        guard let spotifyViewModel, !isRetrievingPersonalizedPlaylist else {
            return
        }

        isRetrievingPersonalizedPlaylist = true

        do {
            var playlists: [Playlist<PlaylistItemsReference>] = try await spotifyViewModel.spotifyRequest {
                    spotifyViewModel.spotify.categoryPlaylists(SpotifyIDs.madeForYouCategory,
                                                               limit: 20)
                    .extendPagesConcurrently(spotifyViewModel.spotify)
                    .collectAndSortByOffset()
                }.compactMap { $0 }

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
        } catch {
            print("unable to get personalized playlists: \(error)")
        }
    }

    public func populateFollowingPlaylist() async {
        guard let spotifyViewModel, !isRetrievingFollowingPlaylist else {
            return
        }

        do {
            let playlists = try await spotifyViewModel.spotifyRequest {
                spotifyViewModel.spotify.currentUserPlaylists()
                    .extendPagesConcurrently(spotifyViewModel.spotify)
                    .collectAndSortByOffset()
            }

            Task { @MainActor in
                followingPlaylists = playlists
            }
        } catch {
            print("unable to get following playlists: \(error)")
        }
    }
}
