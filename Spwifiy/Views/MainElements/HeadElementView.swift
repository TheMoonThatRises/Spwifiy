//
//  HeadElementView.swift
//  Spwifiy
//
//  Created by RangerEmerald on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI
import CachedAsyncImage

public struct HeadElementView: View {

    @Binding var userProfile: SpotifyUser?

    @Binding var currentView: MainViewOptions
    @State var searchText: String = ""

    let collapsed: Bool

    public var body: some View {
        HStack {
            Group {
                NavButton(currentButton: .home,
                          currentView: $currentView) {

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

                NavButton(currentButton: .discover,
                          currentView: $currentView) {

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
                      currentView: $currentView) {

            } label: {
                HStack {
                    Image("spwifiy.search")
                        .resizable()
                        .frame(width: 40, height: 40)

                    Spacer()
                        .frame(width: 5)

                    if currentView == .search {
                        TextField(text: $searchText) {
                            Text("Search")
                                .font(.title3)
                        }
                        .padding(.trailing, 10)
                    } else {
                        Text("Search")
                            .font(.title3)

                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .toButton()

            Spacer()

            Group {
                NavButton(currentButton: .notification,
                          currentView: $currentView) {

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
                          currentView: $currentView) {

                } label: {
                    Image("spwifiy.settings")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                NavButton(currentButton: .profile,
                          currentView: $currentView) {

                } label: {
                    CachedAsyncImage(url: userProfile?.images?.first?.url, urlCache: .imageCache) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                        case .success(let image):
                            image
                                .resizable()
                        default:
                            Image("spwifiy.profile.default")
                                .resizable()
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                }
                .toButton()
            }
            .foregroundStyle(.fgSecondary)
        }
    }
}
