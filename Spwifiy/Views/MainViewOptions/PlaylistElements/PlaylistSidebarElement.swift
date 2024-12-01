//
//  PlaylistSidebarElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistSidebarElement: View {

    var showFlags: Int

    var imageURL: URL?
    var uri: String

    @Binding var dominantColor: Color
    @Binding var genreList: [String]
    @Binding var artists: [Artist]

    @Binding var selectedArtist: Artist?

    var sidebarSize: CGFloat {
        (showFlags & PlaylistShowFlags.largerSide) > 0 ? 400 : 260
    }

    var body: some View {
        VStack {
            CroppedCachedAsyncImage(url: imageURL,
                                    width: sidebarSize,
                                    height: sidebarSize,
                                    alignment: .center,
                                    clipShape: RoundedRectangle(cornerRadius: 5)) { image in
                let color = image.calculateDominantColor(id: uri)
                dominantColor = color ?? .fgPrimary
            }

            VStack {
                WrapHStack(items: genreList) { item in
                    Text(item)
                        .foregroundStyle(.fgSecondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(.fgSecondary, lineWidth: 1)
                        }
                }

                ScrollView {
                    LazyVStack {
                        ForEach(artists, id: \.id) { artist in
                            Button {
                                selectedArtist = artist
                            } label: {
                                HStack {
                                    CroppedCachedAsyncImage(url: artist.images?.first?.url,
                                                            width: 60,
                                                            height: 60,
                                                            alignment: .center,
                                                            clipShape: Circle())

                                    Text(artist.name)
                                        .font(.title3)

                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .cursorHover(.pointingHand)
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(width: sidebarSize)
        .padding()
    }

}
