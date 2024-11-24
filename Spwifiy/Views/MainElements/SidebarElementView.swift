//
//  SidebarElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

public struct SidebarElementView: View {

    @EnvironmentObject var mainViewModel: MainViewModel

    let collapsed: Bool

    public var body: some View {
        VStack {
            NavButton(currentButton: .library,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.library")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Spacer()
                            .frame(width: 5)

                        Text("My Library")
                            .font(.title3)
                    }

                    Spacer()
                }
                .frame(width: collapsed ? 75 : 170)
            }
            .toButton()

            Spacer()
                .frame(height: 20)

            NavButton(currentButton: .pins,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.pin")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Pins")
                            .font(.title3)

                        Spacer()

                        Image("spwifiy.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                    } else {
                        Spacer()
                    }
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .playlist,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.playlist")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Playlists")
                            .font(.title3)

                        Spacer()

                        Image("spwifiy.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                    } else {
                        Spacer()
                    }
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .likedSongs,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.like")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Liked songs")
                            .font(.title3)
                    }

                    Spacer()
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .saves,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.save")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Saves")
                            .font(.title3)
                    }

                    Spacer()
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .albums,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.album")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Albums")
                            .font(.title3)
                    }

                    Spacer()
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .folders,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.folder")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Folders")
                            .font(.title3)
                    }

                    Spacer()
                }
            }
            .toButton()

            Spacer()
                .frame(height: 5)

            NavButton(currentButton: .artists,
                      currentView: $mainViewModel.currentView) {

            } label: {
                HStack {
                    Image("spwifiy.artist")
                        .resizable()
                        .frame(width: 40, height: 40)

                    if !collapsed {
                        Text("Artists")
                            .font(.title3)
                    }

                    Spacer()
                }
            }
            .toButton()
        }
        .fixedSize()
    }
}
