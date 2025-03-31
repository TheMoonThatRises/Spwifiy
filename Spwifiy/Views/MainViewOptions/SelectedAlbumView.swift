//
//  SelectedAlbumView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct SelectedAlbumView: View {

    private var showFlags: Int = CollectionShowFlags.largerSide

    @StateObject var selectedAlbumViewModel: SelectedAlbumViewModel

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var selectedArtist: Artist?

    var playingId: String? {
        selectedAlbumViewModel.album?.id
    }

    init(album: Album,
         spotifyCache: SpotifyCache,
         avAudioPlayer: AVAudioPlayer,
         selectedArtist: Binding<Artist?>) {
        self._selectedAlbumViewModel = StateObject(
            wrappedValue: SelectedAlbumViewModel(spotifyCache: spotifyCache, albumId: album.id)
        )

        self.avAudioPlayer = avAudioPlayer

        self._selectedArtist = selectedArtist
    }

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack(alignment: .leading) {
                    SongCollectionTopElement(playingId: playingId,
                                             playlist: .constant(nil),
                                             album: .constant(selectedAlbumViewModel.album),
                                             avAudioPlayer: avAudioPlayer,
                                             tracks: $selectedAlbumViewModel.tracks,
                                             totalDuration: $selectedAlbumViewModel.totalDuration,
                                             searchText: $selectedAlbumViewModel.searchText,
                                             selectedArtist: $selectedArtist)

                    Spacer()
                        .frame(height: 20)

                    SongCollectionListElement(showFlags: showFlags,
                                              playingId: playingId,
                                              avAudioPlayer: avAudioPlayer,
                                              tracks: $selectedAlbumViewModel.tracks,
                                              savedTracks: $selectedAlbumViewModel.savedTracks,
                                              selectedArtist: $selectedArtist,
                                              selectedAlbum: .constant(nil))

                    Spacer()
                        .frame(height: 10)

                    VStack(alignment: .leading) {
                        ForEach(selectedAlbumViewModel.album?.copyrights ?? []) { copyright in
                            Text(copyright.text)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.fgSecondary)
                }
                .padding()

                Spacer()

                if geom.size.width > 800 {
                    SongCollectionSidebarElement(showFlags: showFlags,
                                                 imageURL: selectedAlbumViewModel.album?.images?.first?.url,
                                                 uri: selectedAlbumViewModel.album?.uri ?? "",
                                                 dominantColor: $selectedAlbumViewModel.dominantColor,
                                                 genreList: $selectedAlbumViewModel.genreList,
                                                 artists: $selectedAlbumViewModel.artists,
                                                 selectedArtist: $selectedArtist)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selectedAlbumViewModel.linearGradient)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .task {
            await selectedAlbumViewModel.updateSongCollectionInfo()
        }
    }
}
