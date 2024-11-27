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
                        case .home:
                            HomeView(spotifyDataViewModel: spotifyDataViewModel,
                                     mainViewModel: mainViewModel)
                        case .selectedPlaylist:
                            if let selectedPlaylist = mainViewModel.selectedPlaylist {
                                SelectedPlaylistView(selectedPlaylistViewModel:
                                    SelectedPlaylistViewModel(
                                        spotifyCache: spotifyCache,
                                        playlist: selectedPlaylist
                                    )
                                )
                            } else {
                                Text("Unable to get selected playlist")
                                    .font(.title)
                            }
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
