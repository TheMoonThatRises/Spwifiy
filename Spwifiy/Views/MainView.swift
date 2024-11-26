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
    @ObservedObject var cacheViewModel: CacheViewModel

    @ObservedObject var mainViewModel: MainViewModel

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack {
                    SidebarElementView(mainViewModel: mainViewModel,
                                       collapsed: geom.size.width < 1020)

                    Spacer()
                }

                VStack {
                    HeadElementView(mainViewModel: mainViewModel,
                                    userProfile: $spotifyViewModel.userProfile,
                                    collapsed: geom.size.width < 1020)

                    Spacer()

                    Group {
                        switch mainViewModel.currentView {
                        case .home:
                            HomeView(spotifyDataViewModel: spotifyDataViewModel,
                                     mainViewModel: mainViewModel)
                                .task {
                                    await spotifyDataViewModel.populatePersonalizedPlaylists()
                                }
                                .task {
                                    await spotifyDataViewModel.populateTopArtists()
                                }
                        case .selectedPlaylist:
                            if let selectedPlaylist = mainViewModel.selectedPlaylist,
                               let viewModel = cacheViewModel.getPlaylist(playlist: selectedPlaylist) {
                                SelectedPlaylistView(selectedPlaylistViewModel: viewModel)
                            } else {
                                Text("Unable to get selected playlist")
                            }
                        default:
                            Text("Unknown error")
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
