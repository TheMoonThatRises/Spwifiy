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
                        PlaylistItemView(playlist: playlist)
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

struct PlaylistItemView: View {

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
                    .lineLimit(1)

                Spacer()

                Text(String(playlist.items.total))
                    .foregroundStyle(dominantColor)
            }
            .font(.callout)

            Spacer()
                .frame(height: 10)

            Text(playlist.description?.removeHTML() ?? "No description provided")
                .foregroundStyle(.fgSecondary)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)

            Spacer()
        }
        .frame(width: 170)
    }

}
