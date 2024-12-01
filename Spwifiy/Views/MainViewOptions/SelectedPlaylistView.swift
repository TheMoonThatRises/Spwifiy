//
//  SelectedPlaylistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

class PlaylistShowFlags {
    static let none = 1 << 1
    static let album = 1 << 2
    static let largerSide = 1 << 3
    static let noSongListTitle = 1 << 4
}

struct SelectedPlaylistView: View {

    var showFlags: Int

    @StateObject var selectedPlaylistViewModel: SelectedPlaylistViewModel

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    init(showFlags: Int,
         spotifyCache: SpotifyCache,
         playlist: Playlist<PlaylistItemsReference>,
         selectedArtist: Binding<Artist?>,
         selectedAlbum: Binding<Album?>) {
        self.showFlags = showFlags

        self._selectedPlaylistViewModel = StateObject(
            wrappedValue: SelectedPlaylistViewModel(spotifyCache: spotifyCache,
                                                    playlist: playlist)
        )

        self._selectedArtist = selectedArtist
        self._selectedAlbum = selectedAlbum
    }

    var body: some View {
        Group {
            if let playlist = selectedPlaylistViewModel.playlistDetails {
                HStack {
                    VStack(alignment: .leading) {
                        PlaylistTopElement(playlist: $selectedPlaylistViewModel.playlistDetails,
                                           album: .constant(nil),
                                           totalDuration: $selectedPlaylistViewModel.totalDuration,
                                           searchText: $selectedPlaylistViewModel.searchText)

                        Spacer()
                            .frame(height: 20)

                        PlaylistSongListElement(showFlags: showFlags,
                                                tracks: $selectedPlaylistViewModel.tracks,
                                                savedTracks: $selectedPlaylistViewModel.savedTracks,
                                                selectedArtist: $selectedArtist,
                                                selectedAlbum: $selectedAlbum)

                        Spacer()
                    }
                    .padding()

                    Spacer()

                    PlaylistSidebarElement(showFlags: showFlags,
                                           imageURL: playlist.images.first?.url,
                                           uri: playlist.uri,
                                           dominantColor: $selectedPlaylistViewModel.dominantColor,
                                           genreList: $selectedPlaylistViewModel.genreList,
                                           artists: $selectedPlaylistViewModel.artists,
                                           selectedArtist: $selectedArtist)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selectedPlaylistViewModel.linearGradient)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Text("Fetching playlist...")
                    .font(.title)
            }
        }
        .task {
            await selectedPlaylistViewModel.updatePlaylistInfo()
        }
    }
}
