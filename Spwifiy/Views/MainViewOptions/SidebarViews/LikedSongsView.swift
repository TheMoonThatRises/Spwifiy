//
//  LikedSongsView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

enum DisplayType {
    case list, grid
}

struct LikedSongsView: View {

    @StateObject var likedSongsViewModel: LikedSongsViewModel

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    init(spotifyCache: SpotifyCache,
         selectedArtist: Binding<Artist?>,
         selectedAlbum: Binding<Album?>) {
        self._likedSongsViewModel = StateObject(
            wrappedValue: LikedSongsViewModel(spotifyCache: spotifyCache)
        )

        self._selectedArtist = selectedArtist
        self._selectedAlbum = selectedAlbum
    }

    var body: some View {
        VStack {
            HStack {
                Button {

                } label: {
                    Image("spwifiy.add.simple")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Spacer()

                NavButton(currentButton: .list, currentView: $likedSongsViewModel.displayType) {

                } label: {
                    Image("spwifiy.list")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                NavButton(currentButton: .grid, currentView: $likedSongsViewModel.displayType) {

                } label: {
                    Image("spwifiy.grid")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .toButton()

                Button {

                } label: {
                    HStack {
                        ZStack {
                            Image("spwifiy.arrow.up")
                                .resizable()
                                .frame(width: 40, height: 40)

                            Image("spwifiy.arrow.down")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .offset(x: 15)
                        }

                        Text("Recent")
                    }
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    HStack {
                        Image("spwifiy.filter")
                            .resizable()
                            .frame(width: 40, height: 40)

                        Text("Filter: All")
                    }
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                ExpandSearch(searchText: $likedSongsViewModel.searchText)
            }
            .foregroundStyle(.fgSecondary)

            Spacer()
                .frame(height: 20)

            PlaylistSongListElement(showFlags: 0,
                                    tracks: $likedSongsViewModel.tracks,
                                    savedTracks: .constant([]),
                                    selectedArtist: $selectedArtist,
                                    selectedAlbum: $selectedAlbum)
        }
        .padding()
        .task {
            await likedSongsViewModel.updatePlaylistInfo()
        }
    }

}
