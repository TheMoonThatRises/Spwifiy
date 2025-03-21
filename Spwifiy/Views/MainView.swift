//
//  MainView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI
import SpotifyWebAPI
import AlertToast

struct MainView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel
    @ObservedObject var spotifyDataViewModel: SpotifyDataViewModel

    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    @ObservedObject var spotifyCache: SpotifyCache

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack {
                    SidebarElementView(mainViewModel: mainViewModel,
                                       collapsed: geom.size.width < 1020)

                    Spacer()
                }

                VStack {
                    HeadElementView(spotifyViewModel: spotifyViewModel,
                                    mainViewModel: mainViewModel,
                                    userProfile: $spotifyViewModel.userProfile,
                                    collapsed: geom.size.width < 1020)

                    Spacer()

                    HStack {
                        Group {
                            switch mainViewModel.currentViewAnimated {
                                // default view
                            case .home:
                                HomeView(spotifyDataViewModel: spotifyDataViewModel,
                                         mainViewModel: mainViewModel)
                            case .search:
                                SearchView(avAudioPlayer: avAudioPlayer,
                                           searchViewModel: searchViewModel,
                                           selectedArtist: $mainViewModel.selectedArtist,
                                           selectedAlbum: $mainViewModel.selectedAlbum,
                                           selectedPlaylist: $mainViewModel.selectedPlaylist)
                                    .onDisappear {
                                        mainViewModel.searchText = ""
                                    }
                            case .settings:
                                SettingsView(settingsViewModel: settingsViewModel,
                                             avAudioPlayer: avAudioPlayer)

                                // sidebar views
                            case .likedSongs:
                                LikedSongsView(spotifyCache: spotifyCache,
                                               avAudioPlayer: avAudioPlayer,
                                               selectedArtist: $mainViewModel.selectedArtist,
                                               selectedAlbum: $mainViewModel.selectedAlbum)

                                // layers deep abstracted view
                            case .selectedPlaylist:
                                if let selectedPlaylist = mainViewModel.selectedPlaylist {
                                    SelectedPlaylistView(spotifyCache: spotifyCache,
                                                         avAudioPlayer: avAudioPlayer,
                                                         playlist: selectedPlaylist,
                                                         selectedArtist: $mainViewModel.selectedArtist,
                                                         selectedAlbum: $mainViewModel.selectedAlbum
                                    )
                                } else {
                                    Text("Unable to get selected playlist")
                                        .font(.title)
                                }
                            case .selectedArtist:
                                if let artist = mainViewModel.selectedArtist {
                                    ArtistView(spotifyCache: spotifyCache,
                                               artist: artist,
                                               avAudioPlayer: avAudioPlayer)
                                } else {
                                    Text("Unable to get selected artist")
                                        .font(.title)
                                }
                            case .selectedAlbum:
                                if let album = mainViewModel.selectedAlbum {
                                    SelectedAlbumView(album: album,
                                                      spotifyCache: spotifyCache,
                                                      avAudioPlayer: avAudioPlayer,
                                                      selectedArtist: $mainViewModel.selectedArtist)
                                } else {
                                    Text("Unable to get selected album")
                                        .font(.title)
                                }

                            // unimplemented views
                            default:
                                Text("Unknown error")
                                    .font(.title)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.fgTertiary, lineWidth: 0.5)
                                .allowsHitTesting(false)
                        }

                        if mainViewModel.showQueueView {
                            ZStack(alignment: .leading) {
                                Color.clear
                                    .frame(width: 5)
                                    .cursorHover(.resizeLeftRight)
                                    .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                            .onChanged { gesture in
                                                let newValue = mainViewModel.queueViewWidth - gesture.translation.width
                                                mainViewModel.queueViewWidth = max(min(newValue, 600), 200)
                                            }
                                    )

                                QueueElementView(avAudioPlayer: avAudioPlayer,
                                                 selectedArtist: $mainViewModel.selectedArtist)
                                .frame(width: mainViewModel.queueViewWidth)
                                .frame(maxHeight: .infinity)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.fgTertiary, lineWidth: 0.5)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }

                    PlayingElementView(avAudioPlayer: avAudioPlayer,
                                       selectedArtist: $mainViewModel.selectedArtist,
                                       selectedAlbum: $mainViewModel.selectedAlbum,
                                       showQueueView: $mainViewModel.showQueueView)
                }
            }
            .padding()
        }
        .sheet(isPresented: $spotifyViewModel.isAuthenticating) {
            AttemptingReauthSheet()
        }
        .sheet(isPresented: $mainViewModel.showLogoutSheet) {
            LogoutConfirmSheet(logout: spotifyViewModel.logout,
                              showLogoutSheet: $mainViewModel.showLogoutSheet)
        }
        .onChange(of: mainViewModel.searchText) { text in
            searchViewModel.search(spotifyViewModel: spotifyViewModel, query: text)
        }
        .task {
            await spotifyViewModel.loadUserProfile()
        }
    }
}

struct AttemptingReauthSheet: View {
    var body: some View {
        VStack {
            Text("Attempting to reauthorize Spwifiy client (spotify token unauthorized).")

            Text("Double check to make sure your system clock has not drifted.")

            HStack {
                Spacer()

                Button {
                    exit(1)
                } label: {
                    Text("Force quit")
                }
            }
        }
        .padding()
    }
}

struct LogoutConfirmSheet: View {

    let logout: () -> Void

    @Binding var showLogoutSheet: Bool

    var body: some View {
        VStack {
            Text("Do you want to logout?")

            HStack {
                Spacer()

                Button {
                    showLogoutSheet.toggle()
                } label: {
                    Text("Cancel")
                }

                Button {
                    logout()
                    showLogoutSheet.toggle()
                } label: {
                    Text("Logout")
                }
            }
        }
        .padding()
    }

}
