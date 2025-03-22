//
//  FollowingArtistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct FollowingArtistView: View {

    @StateObject var followingArtistViewModel: FollowingArtistViewModel

    @Binding var artists: [Artist]
    @Binding var selectedArtist: Artist?

    init(artists: Binding<[Artist]>, selectedArtist: Binding<Artist?>) {
        self._followingArtistViewModel = StateObject(
            wrappedValue: FollowingArtistViewModel()
        )

        self._artists = artists
        self._selectedArtist = selectedArtist
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()

                NavButton(currentButton: .list, currentView: $followingArtistViewModel.displayType) {

                } label: {
                    Image("spwifiy.list")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                NavButton(currentButton: .grid, currentView: $followingArtistViewModel.displayType) {

                } label: {
                    Image("spwifiy.grid")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                ExpandSearch(searchText: $followingArtistViewModel.searchText)
            }

            ScrollView {
                if followingArtistViewModel.displayType == .list {
                    FollowingArtistListView(filterArtists: $followingArtistViewModel.filterArtists,
                                            selectedArtist: $selectedArtist)
                } else {
                    FollowingArtistGridView(filterArtists: $followingArtistViewModel.filterArtists,
                                            selectedArtist: $selectedArtist)
                }
            }
        }
        .onChange(of: artists) { _ in
            followingArtistViewModel.onFilterChange(artists: artists)
        }
        .onChange(of: followingArtistViewModel.searchText) { _ in
            followingArtistViewModel.onFilterChange(artists: artists)
        }
        .padding()
    }

}

struct FollowingArtistListView: View {

    @Binding var filterArtists: [Artist]
    @Binding var selectedArtist: Artist?

    var body: some View {
        LazyVStack {
            ForEach(filterArtists, id: \.id) { artist in
                Button {
                    selectedArtist = artist
                } label: {
                    HStack(alignment: .center, spacing: 15) {
                        CroppedCachedAsyncImage(url: artist.images?.first?.url,
                                                width: 100,
                                                height: 100,
                                                alignment: .center,
                                                clipShape: Circle())

                        Spacer()
                            .frame(width: 20)

                        Text(artist.name)
                            .foregroundStyle(.fgPrimary)
                            .font(.callout)

                        Spacer()
                    }
                    .contentShape(.rect)

                    if artist != filterArtists.last {
                        Spacer()
                            .frame(height: 15)
                    }
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
                .id(artist.id)
            }
        }
    }

}

struct FollowingArtistGridView: View {

    @Binding var filterArtists: [Artist]
    @Binding var selectedArtist: Artist?

    let columns: [GridItem] = [
        .init(.adaptive(minimum: 170))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(filterArtists, id: \.id) { artist in
                Button {
                    selectedArtist = artist
                } label: {
                    ArtistItemView(artist: artist)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
                .id(artist.id)
            }
        }
    }

}
