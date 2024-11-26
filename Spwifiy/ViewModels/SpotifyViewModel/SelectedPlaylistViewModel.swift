//
//  SelectedPlaylistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI

class SelectedPlaylistViewModel: ObservableObject {

    private let spotifyViewModel: SpotifyViewModel

    private let playlist: Playlist<PlaylistItemsReference>

    private var isFetchingPlaylistDetails: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    @Published var playlistDetails: Playlist<PlaylistItems>?
    @Published var dominantColor: Color = .fgPrimary

    @Published var totalDuration: HumanFormat?

    @Published var didSelectSearch: Bool = false
    @Published var searchText: String = ""

    init(spotifyViewModel: SpotifyViewModel, playlist: Playlist<PlaylistItemsReference>) {
        self.spotifyViewModel = spotifyViewModel
        self.playlist = playlist
    }

    public func fetchPlaylistDetails() {
        guard !isFetchingPlaylistDetails else {
            return
        }

        isFetchingPlaylistDetails = true

        spotifyViewModel.spotify.playlist(self.playlist.uri)
            .sink { _ in

            } receiveValue: { playlistDetails in
                Task { @MainActor in
                    defer {
                        self.isFetchingPlaylistDetails = false
                    }

                    self.playlistDetails = playlistDetails
//                    print(playlistDetails)

                    self.totalDuration = self.playlistDetails?
                        .items
                        .items
                        .map { $0.item?.durationMS ?? 0 }
                        .reduce(0, +)
                        .humanRedable
                }
            }
            .store(in: &cancellables)
    }

}
