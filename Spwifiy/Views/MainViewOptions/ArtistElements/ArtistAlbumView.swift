//
//  ArtistAlbumView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistAlbumView: View {

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var filteredAlbums: [Album]
    @Binding var selectedAlbum: Album?

    @Binding var displayType: DisplayType

    var body: some View {
        ScrollView {
            if displayType == .list {

            } else {
                ArtistAlbumGridView(filteredAlbums: $filteredAlbums,
                                    selectedAlbum: $selectedAlbum)
            }
        }
    }

}

struct ArtistAlbumGridView: View {

    @Binding var filteredAlbums: [Album]
    @Binding var selectedAlbum: Album?

    let columns: [GridItem] = [
        .init(.adaptive(minimum: 170))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(filteredAlbums, id: \.id) { album in
                Button {
                    selectedAlbum = album
                } label: {
                    AlbumItemView(album: album)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
                .id(album.id)
            }
        }
    }

}
