//
//  HorizontalArtistScroll.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct HorizontalArtistScroll: View {

    @Binding var artists: [Artist]

    @Binding var selectedArtist: Artist?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(artists, id: \.uri) { artist in
                    Button {
                        selectedArtist = artist
                    } label: {
                        ArtistItemView(artist: artist)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                    .id(artist.id)

                    if artist != artists.last {
                        Spacer()
                            .frame(width: 20)
                    }
                }
            }
        }
    }

}

struct ArtistItemView: View {

    var artist: Artist

    var body: some View {
        VStack(alignment: .center) {
            CroppedCachedAsyncImage(url: artist.images?.first?.url,
                                    width: 170,
                                    height: 170,
                                    alignment: .center,
                                    clipShape: Circle())

            Spacer()
                .frame(height: 20)

            Text(artist.name)
                .foregroundStyle(.fgPrimary)
                .font(.callout)

            Spacer()
        }
        .frame(width: 170)
    }

}
