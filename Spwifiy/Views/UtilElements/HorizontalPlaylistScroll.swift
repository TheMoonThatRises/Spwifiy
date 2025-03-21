//
//  HorizontalPlaylistScroll.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct HorizontalPlaylistScroll: View {

    @Binding var playlists: [Playlist<PlaylistItemsReference>]

    @Binding var selectedPlaylist: Playlist<PlaylistItemsReference>?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
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
            }
        }
    }

}
