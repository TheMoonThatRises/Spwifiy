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
                            playlists: $spotifyDataViewModel.followingPlaylists,
                            artists: .constant([]))

                HomeViewRow(title: "Your Favorite Artists",
                            selectedPlaylist: $mainViewModel.selectedPlaylist,
                            selectedArtist: $mainViewModel.selectedArtist,
                            playlists: .constant([]),
                            artists: $spotifyDataViewModel.topArtists)

                Spacer()
            }
        }
        .task {
            await spotifyDataViewModel.populateFollowingPlaylist()
        }
        .task {
            await spotifyDataViewModel.populateTopArtists()
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

    @Binding var playlists: [Playlist<PlaylistItemsReference>]
    @Binding var artists: [Artist]

    @State var showMoreOption: Bool = false

    var body: some View {
        if playlists.count > 0 || artists.count > 0 {
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
                        .presentationBackground(.bgPrimary)
                    }
                }

                Spacer()
                    .frame(height: 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        if playlists.count > 0 {
                            ForEach(playlists, id: \.uri) { playlist in
                                Button {
                                    withAnimation(.defaultAnimation) {
                                        selectedPlaylist = playlist
                                    }
                                } label: {
                                    HomeViewPlaylistItem(playlist: playlist)
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .cursorHover(.pointingHand)
                                .id(playlist.id)

                                if playlist != playlists.last {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        } else if artists.count > 0 {
                            ForEach(artists, id: \.uri) { artist in
                                Button {
                                    selectedArtist = artist
                                } label: {
                                    HomeViewArtistItem(artist: artist)
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .cursorHover(.pointingHand)
                                .id(artist.id)

                                if artist != artists.last {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

}

struct HomeViewPlaylistItem: View {

    var playlist: Playlist<PlaylistItemsReference>

    @State var dominantColor: Color = .fgPrimary

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center, spacing: 2) {
                UnevenRoundedRectangle(topLeadingRadius: 5, topTrailingRadius: 5)
                    .fill(dominantColor.opacity(0.2))
                    .frame(width: 133, height: 3)

                UnevenRoundedRectangle(topLeadingRadius: 5, topTrailingRadius: 5)
                    .fill(dominantColor.opacity(0.4))
                    .frame(width: 154, height: 6)

                CroppedCachedAsyncImage(url: playlist.images.first?.url,
                                        width: 170,
                                        height: 170,
                                        alignment: .center,
                                        clipShape: RoundedRectangle(cornerRadius: 5)) { image in
                    dominantColor = image.calculateDominantColor(id: playlist.uri) ?? .fgPrimary
                }
            }

            HStack {
                Text(playlist.name)
                    .foregroundStyle(.fgPrimary)

                Spacer()

                Text(String(playlist.items.total))
                    .foregroundStyle(dominantColor)
            }
            .font(.callout)

            Spacer()
                .frame(height: 15)

            if let description = playlist.description?.replacingOccurrences(of: "<a href=(.+?)>(.+?)</a>",
                                                                            with: "$2",
                                                                            options: .regularExpression,
                                                                            range: nil) {
                Text(description)
                    .foregroundStyle(.fgSecondary)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }

            Spacer()
        }
        .frame(width: 170)
    }

}

struct HomeViewArtistItem: View {

    var artist: Artist

    var body: some View {
        VStack(alignment: .center) {
            CroppedCachedAsyncImage(url: artist.images?.first?.url,
                                    width: 170,
                                    height: 170,
                                    alignment: .center,
                                    clipShape: Circle())

            Spacer()
                .frame(height: 20)

            Text(artist.name)
                .foregroundStyle(.fgPrimary)
                .font(.callout)

            Spacer()
        }
        .frame(width: 170)
    }

}
