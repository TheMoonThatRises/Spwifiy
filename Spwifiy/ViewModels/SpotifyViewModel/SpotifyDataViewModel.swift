//
//  SpotifyDataViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/25/24.
//

import SwiftUI
import Combine
import SpotifyWebAPI

class SpotifyDataViewModel: ObservableObject {

    var spotifyViewModel: SpotifyViewModel?

    var isRetrievingPersonalizedPlaylist: Bool = false
    var isRetrievingTopArtists: Bool = false
    var isRetrievingFollowingPlaylist: Bool = false

    @Published public var dailyMixes: [Playlist<PlaylistItemsReference>] = []
    @Published public var typeMixes: [Playlist<PlaylistItemsReference>] = []
    @Published public var repeatRewindMixes: [Playlist<PlaylistItemsReference>] = []
    @Published public var blends: [Playlist<PlaylistItemsReference>] = []
    @Published public var otherPlaylists: [Playlist<PlaylistItemsReference>] = []

    @Published public var followingPlaylists: [Playlist<PlaylistItemsReference>] = []

    @Published public var topArtists: [Artist] = []
    @Published public var followedArtists: [Artist] = []

    public func setSpotifyViewModel(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
    }
}
