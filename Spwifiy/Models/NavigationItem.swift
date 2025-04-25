//
//  NavigationItem.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/29/25.
//

import SpotifyWebAPI

enum NavigationItem: Equatable {
    // navigation views
    case homeView
    case discoverView
    case searchView(String)                                       // search text
    case notificationView
    case settingsView
    case profileView

    // sidebar views
    case libraryView
    case pinsView
    case playlistView
    case likedSongsView
    case savesView
    case albumsView
    case foldersView
    case followingArtistView

    // deep views
    case selectedPlaylistView(Playlist<PlaylistItemsReference>?)   // playlist item
    case selectedArtistView(Artist?, ArtistViewModel.CurrentView)  // artist struct and tab in view
    case selectedAlbumView(Album?)                                 // album item

    // misc views
    case lyrics
}
