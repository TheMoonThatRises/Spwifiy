//
//  SelectedPlaylistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

struct SelectedPlaylistView: View {

    private var showFlags: Int = CollectionShowFlags.showAlbum

    @StateObject var selectedPlaylistViewModel: SelectedPlaylistViewModel

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    var playingId: String? {
        selectedPlaylistViewModel.playlistDetails?.id
    }

    init(spotifyCache: SpotifyCache,
         avAudioPlayer: AVAudioPlayer,
         playlist: Playlist<PlaylistItemsReference>,
         selectedArtist: Binding<Artist?>,
         selectedAlbum: Binding<Album?>) {
        self._selectedPlaylistViewModel = StateObject(
            wrappedValue: SelectedPlaylistViewModel(spotifyCache: spotifyCache,
                                                    playlist: playlist)
        )

        self.avAudioPlayer = avAudioPlayer

        self._selectedArtist = selectedArtist
        self._selectedAlbum = selectedAlbum
    }

    var body: some View {
        GeometryReader { geom in
            if let playlist = selectedPlaylistViewModel.playlistDetails {
                HStack {
                    VStack(alignment: .leading) {
                        SongCollectionTopElement(playingId: playingId,
                                                 playlist: $selectedPlaylistViewModel.playlistDetails,
                                                 album: .constant(nil),
                                                 avAudioPlayer: avAudioPlayer,
                                                 tracks: $selectedPlaylistViewModel.tracks,
                                                 totalDuration: $selectedPlaylistViewModel.totalDuration,
                                                 searchText: $selectedPlaylistViewModel.searchText)

                        Spacer()
                            .frame(height: 20)

                        SongCollectionListElement(showFlags: showFlags,
                                                  playingId: playingId,
                                                  avAudioPlayer: avAudioPlayer,
                                                  tracks: $selectedPlaylistViewModel.tracks,
                                                  savedTracks: $selectedPlaylistViewModel.savedTracks,
                                                  selectedArtist: $selectedArtist,
                                                  selectedAlbum: $selectedAlbum)

                        Spacer()
                    }
                    .padding()

                    Spacer()

                    if geom.size.width > 800 {
                        SongCollectionSidebarElement(showFlags: showFlags,
                                                     imageURL: playlist.images.first?.url,
                                                     uri: playlist.uri,
                                                     dominantColor: $selectedPlaylistViewModel.dominantColor,
                                                     genreList: $selectedPlaylistViewModel.genreList,
                                                     artists: $selectedPlaylistViewModel.artists,
                                                     selectedArtist: $selectedArtist)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selectedPlaylistViewModel.linearGradient)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Text("Fetching playlist...")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task {
            await selectedPlaylistViewModel.updateSongCollectionInfo()
        }
    }
}
