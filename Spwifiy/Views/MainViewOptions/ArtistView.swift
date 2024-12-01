//
//  ArtistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import CachedAsyncImage
import SpotifyWebAPI

struct ArtistView: View {

    @StateObject var artistViewModel: ArtistViewModel

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self._artistViewModel = StateObject(
            wrappedValue: ArtistViewModel(spotifyCache: spotifyCache, artist: artist)
        )
    }

    var body: some View {
        GeometryReader { geom in
            VStack {
                ZStack {
                    Group {
                        if let backgroundImageURL = artistViewModel.backgroundImageURL {
                            CroppedCachedAsyncImage(url: backgroundImageURL,
                                                    width: geom.size.width,
                                                    height: 400,
                                                    alignment: .top,
                                                    clipShape: RoundedRectangle(cornerRadius: 5))
                        } else {
                            CroppedCachedAsyncImage(url: artistViewModel.artist.images?.first?.url,
                                                    width: geom.size.width,
                                                    height: 400,
                                                    alignment: .center,
                                                    clipShape: RoundedRectangle(cornerRadius: 5))
                        }
                    }
                    .overlay(
                        Rectangle()
                            .foregroundStyle(
                                LinearGradient(colors: [.clear, .clear, .bgSecondary.opacity(0.8)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                    )

                    VStack {
                        Spacer()

                        HStack {
                            VStack(alignment: .leading) {
                                Text(artistViewModel.artist.name)
                                    .font(.satoshiBlack(60))
                                    .fontWeight(.black)
                                    .foregroundStyle(.fgPrimary)

                                Spacer()
                                    .frame(height: 25)

                                HStack {
                                    if let monthlyListeners = artistViewModel.monthlyListeners {
                                        Text(monthlyListeners.formatted())
                                    } else {
                                        ProgressView()
                                    }

                                    Text("monthly listeners")
                                }
                                .font(.title2)
                            }
                            .padding()

                            Spacer()
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                }
                .fixedSize()

                Spacer()
            }
        }
        .task {
            await artistViewModel.updateArtistDetails()
        }
    }

}
