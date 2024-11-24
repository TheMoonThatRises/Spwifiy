//
//  MainView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI
import SpotifyWebAPI

struct MainView: View {

    @EnvironmentObject var spotifyViewModel: SpotifyViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel

    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack {
                    SidebarElementView(collapsed: geom.size.width < 1020)
                        .environmentObject(mainViewModel)

                    Spacer()
                }

                VStack {
                    HeadElementView(collapsed: geom.size.width < 1020)
                        .environmentObject(mainViewModel)

                    Spacer()

                    Group {
                        switch mainViewModel.currentView {
                        case .home:
                            HomeView(personalizedPlaylists: homeViewModel.personalizedPlaylists,
                                     userArtists: homeViewModel.userArtists)
                                .environmentObject(homeViewModel)
                                .environmentObject(mainViewModel)
                        case .selectedPlaylist:
                            if let selectedPlaylist = mainViewModel.selectedPlaylist {
                                SelectedPlaylistView(
                                    selectedPlaylistViewModel:
                                        SelectedPlaylistViewModel(spotifyViewModel: spotifyViewModel,
                                                                  playlist: selectedPlaylist)
                                )
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
                    }

                    PlayingElementView()
                }
            }
            .padding()
        }
        .task {
            mainViewModel.userProfile = await spotifyViewModel.getUserProfile()
        }
    }
}
