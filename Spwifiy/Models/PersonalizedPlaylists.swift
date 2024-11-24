//
//  PersonalizedPlaylists.swift
//  Spwifiy
//
//  Created by RangerEmerald on 11/24/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI

class PersonalizedPlaylists: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []

    private let spotifyViewModel: SpotifyViewModel

    @Published public var dailyMixes: [Playlist<PlaylistItemsReference>]
    @Published public var typeMixes: [Playlist<PlaylistItemsReference>]
    @Published public var repeatRewindMixes: [Playlist<PlaylistItemsReference>]
    @Published public var blends: [Playlist<PlaylistItemsReference>]
    @Published public var otherPlaylists: [Playlist<PlaylistItemsReference>]

    init(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
        self.dailyMixes = []
        self.typeMixes = []
        self.repeatRewindMixes = []
        self.blends = []
        self.otherPlaylists = []
    }

    private func getPersonalizedPlaylists(offset: Int, limit: Int)
        async -> PagingObject<Playlist<PlaylistItemsReference>?> {
        await withCheckedContinuation { continuation in
            spotifyViewModel.spotify.categoryPlaylists(SpotifyIDs.madeForYouCategory, limit: limit, offset: offset)
                .sink { _ in

                } receiveValue: { playlist in
                    continuation.resume(returning: playlist)
                }
                .store(in: &cancellables)
        }
    }

    public func populatePersonalizedPlaylists() async {
        var playlists: [Playlist<PlaylistItemsReference>] = []

        var result = await getPersonalizedPlaylists(offset: 0, limit: 25)

        while true {
            playlists.append(contentsOf: result.items.compactMap { $0 })

            if playlists.count >= result.total {
                break
            }

            result = await getPersonalizedPlaylists(offset: result.limit + result.offset, limit: 25)
        }

        Task { @MainActor in
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

            if let displayName = await spotifyViewModel.getUserProfile().displayName?.lowercased() {
                blends = playlists.filter {
                    $0.name.lowercased().matches("(\\+ )?\(displayName)( \\+)?")
                }.sorted { $0.name < $1.name }
                playlists.removeAll(where: { blends.contains($0) })
            }

            otherPlaylists = playlists
        }
    }
}
