//
//  PlaylistSidebarElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI
import CachedAsyncImage

struct PlaylistSidebarElement: View {

    var showFlags: Int

    var imageURL: URL?
    var uri: String

    @Binding var dominantColor: Color
    @Binding var genreList: [String]
    @Binding var artists: [Artist]

    var sidebarSize: CGFloat {
        (showFlags & PlaylistShowFlags.largerSide) > 0 ? 400 : 260
    }

    var body: some View {
        VStack {
            CachedAsyncImage(url: imageURL, urlCache: .imageCache) { image in
                image
                    .resizable()
                    .task {
                        let color = image.calculateDominantColor(id: uri)
                        dominantColor = color ?? .fgPrimary
                    }
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
            }
            .scaledToFill()
            .frame(width: sidebarSize, height: sidebarSize, alignment: .center)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 5))

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

                            } label: {
                                HStack {
                                    CachedAsyncImage(url: artist.images?.first?.url,
                                                     urlCache: .imageCache) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .controlSize(.small)
                                    }
                                    .scaledToFill()
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .clipped()
                                    .clipShape(Circle())

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
