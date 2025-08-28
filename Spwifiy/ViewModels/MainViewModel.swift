//
//  MainViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class MainViewModel: ObservableObject {

    @AppStorage("settings.view.showqueueview") var showQueueView: Bool = false
    @AppStorage("settings.view.queueviewwidth") var queueViewWidth: Double = 300

    @Published var currentView: MainViewOptions = .home {
        willSet {
            Task { @MainActor in
                withAnimation(.defaultAnimation) {
                    currentViewAnimated = newValue
                }
            }
        }
        didSet {
            updateNavigationStack()
        }
    }
    @Published var currentViewAnimated: MainViewOptions = .home

    @Published var selectedArtist: Artist? {
        didSet {
            currentView = .selectedArtist
        }
    }
    @Published var selectedPlaylist: Playlist<PlaylistItemsReference>? {
        didSet {
            currentView = .selectedPlaylist
        }
    }
    @Published var selectedAlbum: Album? {
        didSet {
            currentView = .selectedAlbum
        }
    }

    @Published var showLogoutSheet: Bool = false

    @Published var searchText: String = "" {
        didSet {
            if case .searchView = navigationStack.first {
                navigationStack[0] = .searchView(searchText)
            }
        }
    }

    @Published var navigationStack: [NavigationItem] = [] // newest first
    @Published var navigationIndex: Int = 0

    private var shouldUpdateNavStack: Bool = true

    private func updateNavigationStack() {
        if shouldUpdateNavStack {
            let navItem = viewToNav(view: currentView)

            if navigationIndex > 0 {
                navigationStack.removeSubrange(0..<navigationIndex)
            }

            if navigationStack.first != navItem {
                navigationStack.insert(navItem, at: 0)
                navigationIndex = 0
            }
        } else {
            shouldUpdateNavStack = true
        }
    }

    func updateNavigation(navForwards: Bool) {
        if navForwards && navigationIndex > 0 {
            navigationIndex -= 1
        } else if !navForwards && navigationIndex < navigationStack.count - 1 {
            navigationIndex += 1
        }

        shouldUpdateNavStack = false

        navToView(item: navigationStack[navigationIndex])
    }

    public func viewToNav(view: MainViewOptions) -> NavigationItem {
        switch view {
        case .home:
            return .homeView
        case .discover:
            return .discoverView
        case .search:
            return .searchView(searchText)
        case .notification:
            return .notificationView
        case .settings:
            return .settingsView
        case .profile:
            return .profileView
        case .library:
            return .libraryView
        case .pins:
            return .pinsView
        case .playlist:
            return .playlistView
        case .likedSongs:
            return .likedSongsView
        case .saves:
            return .savesView
        case .albums:
            return .albumsView
        case .folders:
            return .foldersView
        case .artists:
            return .followingArtistView
        case .selectedPlaylist:
            return .selectedPlaylistView(selectedPlaylist)
        case .selectedArtist:
            return .selectedArtistView(selectedArtist, .homeView)
        case .selectedAlbum:
            return .selectedAlbumView(selectedAlbum)
        case .lyrics:
            return .lyrics
        }
    }

    public func navToView(item: NavigationItem) {
        switch item {
        case .homeView:
            currentView = .home
        case .discoverView:
            currentView = .discover
        case .searchView(let text):
            currentView = .search
            searchText = text
        case .notificationView:
            currentView = .notification
        case .settingsView:
            currentView = .settings
        case .profileView:
            currentView = .profile
        case .libraryView:
            currentView = .library
        case .pinsView:
            currentView = .pins
        case .playlistView:
            currentView = .playlist
        case .likedSongsView:
            currentView = .likedSongs
        case .savesView:
            currentView = .saves
        case .albumsView:
            currentView = .albums
        case .foldersView:
            currentView = .folders
        case .followingArtistView:
            currentView = .artists
        case .selectedPlaylistView(let playlist):
            selectedPlaylist = playlist
        case .selectedArtistView(let artist, _):
            selectedArtist = artist
        case .selectedAlbumView(let album):
            selectedAlbum = album
        case .lyrics:
            currentView = .lyrics
        }
    }

}
