//
//  FollowingArtistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

class FollowingArtistViewModel: ObservableObject {

    @AppStorage("settings.sidebar.followingartist.displaytype") var displayType: DisplayType = .grid

    @Published var searchText: String = ""
    @Published var filterArtists: [Artist] = []

    func onFilterChange(artists: [Artist]) {
        filterArtists = searchText.isEmpty
            ? artists
            : artists.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
    }

}
