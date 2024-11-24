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

    private var cancellables: Set<AnyCancellable> = []

    @Published var playlistDetails: Playlist<PlaylistItems>?
    @Published var dominantColor: Color = .fgPrimary

    @Published var totalDuration: HumanFormat?

    init(spotifyViewModel: SpotifyViewModel, playlist: Playlist<PlaylistItemsReference>) {
        self.spotifyViewModel = spotifyViewModel
        self.playlist = playlist

        self.spotifyViewModel.spotify.playlist(self.playlist.uri)
            .sink { _ in

            } receiveValue: { playlistDetails in
                Task { @MainActor in
                    self.playlistDetails = playlistDetails
                    print("detailed playlist")
                    print(playlistDetails)

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
