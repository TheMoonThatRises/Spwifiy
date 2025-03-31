//
//  SearchView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/19/25.
//

import SwiftUI
import SpotifyWebAPI
import AlertToast

struct SearchView: View {

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @ObservedObject var searchViewModel: SearchViewModel

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?
    @Binding var selectedPlaylist: Playlist<PlaylistItemsReference>?

    var body: some View {
        if let searchResult = searchViewModel.searchResult {
            ScrollView {
                LazyVStack {
                    if let tracks = searchResult.tracks?.items {
                        SongCollectionListElement(showFlags: searchViewModel.showFlags,
                                                  avAudioPlayer: avAudioPlayer,
                                                  tracks: .constant(Array(tracks.prefix(7))),
                                                  savedTracks: .constant([]),
                                                  selectedArtist: $selectedArtist,
                                                  selectedAlbum: $selectedAlbum)
                            .scrollDisabled(true)
                            .padding()
                    }

                    if let artists = searchResult.artists?.items.prefix(7) {
                        HorizontalScrollSearchView(title: "Artists") {
                            HorizontalArtistScroll(artists: .constant(Array(artists)),
                                                   selectedArtist: $selectedArtist)
                        }
                    }

                    if let albums = searchResult.albums?.items.prefix(7) {
                        HorizontalScrollSearchView(title: "Albums") {
                            HorizontalAlbumScroll(albums: .constant(Array(albums)),
                                                  selectedAlbum: $selectedAlbum)
                        }
                    }

                    if let playlists = searchResult.playlists?.items.prefix(7) {
                        HorizontalScrollSearchView(title: "Playlists") {
                            HorizontalPlaylistScroll(playlists: .constant(Array(playlists)),
                                                     selectedPlaylist: $selectedPlaylist)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            Group {
                if searchViewModel.isSearching {
                    AlertToast(type: .loading)
                } else {
                    Text("Unable to retrieve search result")
                        .font(.title)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

}

struct HorizontalScrollSearchView<Content: View>: View {

    let title: String

    @ViewBuilder let scrollElement: Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(.fgPrimary)
                .font(.title2)
                .bold()

            Spacer()
                .frame(height: 20)

            scrollElement
        }
        .padding()
    }

}
