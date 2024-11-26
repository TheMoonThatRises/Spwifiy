//
//  SpotifyDataViewModel+playlists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import Foundation
import SpotifyWebAPI

extension SpotifyDataViewModel {
    private func getPersonalizedPlaylists(offset: Int, limit: Int)
    async throws -> PagingObject<Playlist<PlaylistItemsReference>?> {
        guard let spotifyViewModel else {
            throw SpwifiyErrors.spotifyNoViewModel
        }

        return try await withCheckedThrowingContinuation { continuation in
            let cancellable = spotifyViewModel.spotify.categoryPlaylists(SpotifyIDs.madeForYouCategory,
                                                                 limit: limit,
                                                                 offset: offset)
                .sink { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { playlist in
                    continuation.resume(returning: playlist)
                }

            Task { @MainActor in
                cancellable
                    .store(in: &cancellables)
            }
        }
    }

    public func populatePersonalizedPlaylists() async {
        guard let spotifyViewModel, !isRetrievingPersonalizedPlaylist else {
            return
        }

        isRetrievingPersonalizedPlaylist = true

        var playlists: [Playlist<PlaylistItemsReference>] = []

        var result = try? await getPersonalizedPlaylists(offset: 0, limit: 25)

        while true {
            if let result {
                playlists.append(contentsOf: result.items.compactMap { $0 })
            }

            if playlists.count >= result?.total ?? 50 {
                break
            }

            result = try? await getPersonalizedPlaylists(offset: (result?.limit ?? 0) + (result?.offset ?? 0),
                                                         limit: 25)
        }

        Task { @MainActor in
            defer {
                isRetrievingPersonalizedPlaylist = false
            }

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
