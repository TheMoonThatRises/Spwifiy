//
//  UserArtists.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI

class UserArtists: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []

    private let spotifyViewModel: SpotifyViewModel

    @Published public var topArtists: [Artist]
    @Published public var followedArtists: [Artist]

    init(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
        self.topArtists = []
        self.followedArtists = []
    }

    public func populateTopArtists() async {
        spotifyViewModel.spotify.currentUserTopArtists(limit: 10)
            .sink { _ in

            } receiveValue: { artists in
                Task { @MainActor in
                    self.topArtists = artists.items
                }
            }
            .store(in: &cancellables)
    }

    public func populatePersonalizedPlaylists() async {
//        var playlists: [Playlist<PlaylistItemsReference>] = []
//
//        var result = await getPersonalizedPlaylists(offset: 0, limit: 25)
//
//        while true {
//            playlists.append(contentsOf: result.items.compactMap { $0 })
//
//            if playlists.count >= result.total {
//                break
//            }
//
//            result = await getPersonalizedPlaylists(offset: result.limit + result.offset, limit: 25)
//        }
//
//        Task { @MainActor in
//            dailyMixes = playlists.filter {
//                $0.name.lowercased().contains("daily mix") ||
//                $0.name.lowercased().contains("discover weekly") ||
//                $0.name.lowercased().contains("release radar")
//            }.sorted { $0.name < $1.name }
//            playlists.removeAll(where: { dailyMixes.contains($0) })
//
//            repeatRewindMixes = playlists.filter {
//                $0.name.lowercased().contains("repeat") ||
//                $0.name.lowercased().contains("rewind")
//            }.sorted { $0.name < $1.name }
//            playlists.removeAll(where: { repeatRewindMixes.contains($0) })
//
//            typeMixes = playlists.filter {
//                $0.name.lowercased().contains("mix")
//            }.sorted { $0.name < $1.name }
//            playlists.removeAll(where: { typeMixes.contains($0) })
//
//            if let displayName = await spotifyViewModel.getUserProfile().displayName?.lowercased() {
//                blends = playlists.filter {
//                    $0.name.lowercased().matches("(\\+ )?\(displayName)( \\+)?")
//                }.sorted { $0.name < $1.name }
//                playlists.removeAll(where: { blends.contains($0) })
//            }
//
//            otherPlaylists = playlists
//        }
    }
}
