//
//  HomeView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

struct HomeView: View {

    @ObservedObject var spotifyDataViewModel: SpotifyDataViewModel
    @ObservedObject var mainViewModel: MainViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    Text("All")
                        .foregroundStyle(.bgPrimary)
                        .font(.title3)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.fgPrimary)
                        )

                    Spacer()

                    Button {

                    } label: {
                        Image("spwifiy.adjust")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.fgSecondary)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                }
                .padding()

//                Depricated due to https://developer.spotify.com/blog/2024-11-27-changes-to-the-web-api
//
//                HomeViewRow(title: "Made For You",
//                            selectedPlaylist: $mainViewModel.selectedPlaylist,
//                            selectedArtist: $mainViewModel.selectedArtist,
//                            playlists: $spotifyDataViewModel.dailyMixes,
//                            artists: .constant([]))
//
//                HomeViewRow(title: "Your Top Mixes",
//                            selectedPlaylist: $mainViewModel.selectedPlaylist,
//                            selectedArtist: $mainViewModel.selectedArtist,
//                            playlists: $spotifyDataViewModel.typeMixes,
//                            artists: .constant([]))

                HomeViewRow(title: "Following Playlists",
                            selectedPlaylist: $mainViewModel.selectedPlaylist,
                            selectedArtist: $mainViewModel.selectedArtist,
                            selectedAlbum: $mainViewModel.selectedAlbum,
                            playlists: $spotifyDataViewModel.followingPlaylists,
                            artists: .constant([]),
                            albums: .constant([]))

                HomeViewRow(title: "Saved Albums",
                            selectedPlaylist: $mainViewModel.selectedPlaylist,
                            selectedArtist: $mainViewModel.selectedArtist,
                            selectedAlbum: $mainViewModel.selectedAlbum,
                            playlists: .constant([]),
                            artists: .constant([]),
                            albums: $spotifyDataViewModel.savedAlbums)

                HomeViewRow(title: "Your Favorite Artists",
                            selectedPlaylist: $mainViewModel.selectedPlaylist,
                            selectedArtist: $mainViewModel.selectedArtist,
                            selectedAlbum: $mainViewModel.selectedAlbum,
                            playlists: .constant([]),
                            artists: $spotifyDataViewModel.topArtists,
                            albums: .constant([]))

                Spacer()
            }
        }
        .task {
            await spotifyDataViewModel.populateFollowingPlaylist()
        }
        .task {
            spotifyDataViewModel.populateTopArtists()
        }
        .task {
            await spotifyDataViewModel.populateSavedAlbums()
        }
//        .task {
//            await spotifyDataViewModel.populatePersonalizedPlaylists()
//        }
    }
}

struct HomeViewRow: View {

    var title: String

    @Binding var selectedPlaylist: Playlist<PlaylistItemsReference>?
    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    @Binding var playlists: [Playlist<PlaylistItemsReference>]
    @Binding var artists: [Artist]
    @Binding var albums: [Album]

    @State var showMoreOption: Bool = false

    var body: some View {
        if playlists.count > 0 || artists.count > 0 || albums.count > 0 {
            VStack {
                HStack {
                    Text(title)
                        .foregroundStyle(.fgPrimary)
                        .font(.title2)
                        .bold()

                    Spacer()

                    Button {

                    } label: {
                        Image("spwifiy.arrow.left")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.fgSecondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {

                    } label: {
                        Image("spwifiy.arrow.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.fgSecondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {
                        showMoreOption.toggle()
                    } label: {
                        Image("spwifiy.more")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.fgSecondary)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                    .popover(isPresented: $showMoreOption, arrowEdge: .leading) {
                        ZStack {
                            Color.bgPrimary
                                .scaleEffect(1.5)

                            VStack(alignment: .leading) {
                                HStack {
                                    Image("spwifiy.pin")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.fgSecondary)

                                    Text("Pin to Home")
                                }

                                HStack {
                                    Image("spwifiy.hide")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.fgSecondary)

                                    Text("Hide this Section")
                                }
                            }
                            .padding()
                        }
                    }
                }

                Spacer()
                    .frame(height: 10)

                if artists.count > 0 {
                    HorizontalArtistScroll(artists: $artists,
                                           selectedArtist: $selectedArtist)
                } else if playlists.count > 0 {
                    HorizontalPlaylistScroll(playlists: $playlists,
                                             selectedPlaylist: $selectedPlaylist)
                } else if albums.count > 0 {
                    HorizontalAlbumScroll(albums: $albums,
                                          selectedAlbum: $selectedAlbum)
                }
            }
            .padding()
        }
    }

}
