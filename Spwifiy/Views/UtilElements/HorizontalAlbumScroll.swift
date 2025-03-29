//
//  HorizontalAlbumScroll.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct HorizontalAlbumScroll: View {

    @Binding var albums: [Album]

    @Binding var selectedAlbum: Album?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(albums, id: \.uri) { album in
                        Button {
                            withAnimation(.defaultAnimation) {
                                selectedAlbum = album
                            }
                        } label: {
                            AlbumItemView(album: album)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .cursorHover(.pointingHand)
                        .id(album.id)

                        if album != albums.last {
                            Spacer()
                                .frame(width: 20)
                        }
                    }
                }
            }
        }
    }

}

struct AlbumItemView: View {

    var album: Album
    var imageOnly: Bool = false

    @State var dominantColor: Color = .fgPrimary

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center, spacing: 2) {
                UnevenRoundedRectangle(topLeadingRadius: 5, topTrailingRadius: 5)
                    .fill(dominantColor.opacity(0.4))
                    .frame(width: 154, height: 8)

                CroppedCachedAsyncImage(url: album.images?.first?.url,
                                        width: 170,
                                        height: 170,
                                        alignment: .center,
                                        clipShape: RoundedRectangle(cornerRadius: 5)) { image in
                    dominantColor = image.calculateDominantColor(id: album.uri ?? album.combId) ?? .fgPrimary
                }
            }

            if !imageOnly {
                HStack {
                    Text(album.name)
                        .foregroundStyle(.fgPrimary)

                    Spacer()

                    Text(String(album.totalTracks ?? 0))
                        .foregroundStyle(dominantColor)
                }
                .font(.callout)

                Spacer()
                    .frame(height: 15)

                if let artists = album.artists?.description {
                    Text(artists)
                        .foregroundStyle(.fgSecondary)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }

                Spacer()
            }
        }
        .frame(width: 170)
    }

}
