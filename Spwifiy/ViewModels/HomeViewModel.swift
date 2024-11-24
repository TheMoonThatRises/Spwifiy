//
//  HomeViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class HomeViewModel: ObservableObject {
    @ObservedObject var spotifyViewModel: SpotifyViewModel

    @ObservedObject var personalizedPlaylists: PersonalizedPlaylists
    @ObservedObject var userArtists: UserArtists

    init(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
        self.personalizedPlaylists = PersonalizedPlaylists(spotifyViewModel: spotifyViewModel)
        self.userArtists = UserArtists(spotifyViewModel: spotifyViewModel)
    }
}
