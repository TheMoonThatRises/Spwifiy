//
//  MainView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI
import SpotifyWebAPI

struct MainView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel
    @ObservedObject var spotifyDataViewModel: SpotifyDataViewModel

    @ObservedObject var mainViewModel: MainViewModel

    @ObservedObject var spotifyCache: SpotifyCache

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

                    Group {
                        switch mainViewModel.currentView {
                        // default view
                        case .home:
                            HomeView(spotifyDataViewModel: spotifyDataViewModel,
                                     mainViewModel: mainViewModel)

                        // sidebar views
                        case .likedSongs:
                            LikedSongsView(spotifyCache: spotifyCache)

                        // layers deep abstracted view
                        case .selectedPlaylist:
                            if let selectedPlaylist = mainViewModel.selectedPlaylist {
                                SelectedPlaylistView(
                                    showFlags: PlaylistShowFlags.none,
                                    spotifyCache: spotifyCache,
                                    playlist: selectedPlaylist,
                                    selectedArtist: $mainViewModel.selectedArtist
                                )
                            } else {
                                Text("Unable to get selected playlist")
                                    .font(.title)
                            }
                        case .selectedArtist:
                            if let artist = mainViewModel.selectedArtist {
                                ArtistView(spotifyCache: spotifyCache, artist: artist)
                            } else {
                                Text("Unable to get selected artist")
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

                    PlayingElementView()
                }
            }
            .padding()
        }
        .onAppear {
            spotifyViewModel.loadUserProfile()
        }
    }
}
