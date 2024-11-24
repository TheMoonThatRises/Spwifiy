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

    @State var currentView: MainViewOptions = .home

    @State var userProfile: SpotifyUser?

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack {
                    SidebarElementView(currentView: $currentView,
                                       collapsed: geom.size.width < 1020)

                    Spacer()
                }

                VStack {
                    HeadElementView(userProfile: $userProfile,
                                    currentView: $currentView,
                                    collapsed: geom.size.width < 1020)

                    Spacer()

                    Group {
                        switch currentView {
                        case .home:
                            HomeView(personalizedPlaylists: homeViewModel.personalizedPlaylists,
                                     userArtists: homeViewModel.userArtists)
                                .environmentObject(homeViewModel)
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
            userProfile = await spotifyViewModel.getUserProfile()
        }
    }
}

#Preview("Spwifiy Homepage Preview") {
    MainView()
        .environment(\.font, .satoshi)
        .background(.bgMain)
}
