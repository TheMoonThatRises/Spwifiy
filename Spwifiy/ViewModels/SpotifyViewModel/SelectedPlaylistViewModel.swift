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

    private let spotifyCache: SpotifyCache
    private let playlist: Playlist<PlaylistItemsReference>
    @Published var playlistDetails: Playlist<PlaylistItems>?

    private var isFetchingPlaylistDetails: Bool = false

    @Published var dominantColor: Color = .fgPrimary

    @Published var totalDuration: HumanFormat?

    @Published var didSelectSearch: Bool = false
    @Published var searchText: String = ""

    init(spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>,
         playlistDetails: Playlist<PlaylistItems>?) {
        self.spotifyCache = spotifyCache
        self.playlist = playlist
        self.playlistDetails = playlistDetails

        self.calcTotalDuration()
    }

    public func fetchPlaylistDetails() {
        guard !isFetchingPlaylistDetails else {
            return
        }

        isFetchingPlaylistDetails = true

        Task { @MainActor in
            defer {
                self.isFetchingPlaylistDetails = false
            }

            do {
                let result = try await spotifyCache.fetchPlaylist(playlistId: playlist.id)

                withAnimation(.defaultAnimation) {
                    self.playlistDetails = result

                    self.calcTotalDuration()
                }
            } catch {
                print("unable to refresh playlist details: \(error)")
            }
        }
    }

    private func calcTotalDuration() {
        totalDuration = playlistDetails?
            .items
            .items
            .map { $0.item?.durationMS ?? 0 }
            .reduce(0, +)
            .humanRedable
    }
}
