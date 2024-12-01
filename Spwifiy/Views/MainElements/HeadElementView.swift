//
//  HeadElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI
import CachedAsyncImage

public struct HeadElementView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel
    @ObservedObject var mainViewModel: MainViewModel

    @Binding var userProfile: SpotifyUser?

    @State var searchText: String = ""
    @FocusState var isSearchFocused: Bool

    let collapsed: Bool

    public var body: some View {
        HStack {
            Group {
                NavButton(currentButton: .home,
                          currentView: $mainViewModel.currentView) {

                } label: {
                    HStack {
                        Image("spwifiy.home.fill")
                            .resizable()
                            .frame(width: 40, height: 40)

                        if !collapsed {
                            Spacer()
                                .frame(width: 5)

                            Text("Home")
                                .font(.title3)

                            Spacer()
                        }
                    }
                    .frame(width: collapsed ? 75 : 170)
                }
                .toButton()

                Spacer()
                    .frame(width: 20)

                NavButton(currentButton: .discover,
                          currentView: $mainViewModel.currentView) {

                } label: {
                    HStack {
                        Image("spwifiy.discover")
                            .resizable()
                            .frame(width: 40, height: 40)

                        if !collapsed {
                            Spacer()
                                .frame(width: 5)

                            Text("Discover")
                                .font(.title3)

                            Spacer()
                        }
                    }
                    .frame(width: collapsed ? 75 : 170)
                }
                .toButton()
            }

            Spacer()

            NavButton(currentButton: .search,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.search")
                        .resizable()
                        .frame(width: 40, height: 40)

                    Spacer()
                        .frame(width: 5)

                    if mainViewModel.currentView == .search {
                        TextField(text: $searchText) {
                            Text("Search")
                                .font(.title3)
                        }
                        .focused($isSearchFocused)
                        .padding(.trailing, 10)
                        .onAppear {
                            isSearchFocused = true
                        }
                    } else {
                        Text("Search")
                            .font(.title3)

                        Spacer()
                    }
                }
                .frame(maxWidth: 300)
            }
            .toButton()

            Spacer()

            Group {
                NavButton(currentButton: .notification,
                          currentView: $mainViewModel.currentView) {

                } label: {
                    Image("spwifiy.news")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                Button {

                } label: {
                    Image("spwifiy.public")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.friends")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                NavButton(currentButton: .settings,
                          currentView: $mainViewModel.currentView) {

                } label: {
                    Image("spwifiy.settings")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                NavButton(currentButton: .profile,
                          currentView: $mainViewModel.currentView) {
                    spotifyViewModel.spotify.authorizationManager.deauthorize()

                    NSApplication.shared.terminate(nil)
                } label: {
                    CroppedCachedAsyncImage(url: userProfile?.images?.first?.url,
                                            width: 40,
                                            height: 40,
                                            alignment: .center,
                                            clipShape: Circle())
                }
                .toButton()
            }
            .foregroundStyle(.fgSecondary)
        }
    }
}
