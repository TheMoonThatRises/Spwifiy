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
        ScrollView {
            VStack {
                GeometryReader { geom in
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

                            HStack(alignment: .bottom) {
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

                                Spacer()

                                HStack(spacing: 15) {
                                    Button {

                                    } label: {
                                        Image("spwifiy.play.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)

                                    Button {

                                    } label: {
                                        Text("Follow")
                                            .font(.satoshiLight(12))
                                            .padding()
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 40)
                                                    .foregroundStyle(.fgPrimary.opacity(0.3))
                                                    .allowsHitTesting(false)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)

                                    Button {

                                    } label: {
                                        Image("spwifiy.add.playlist")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)

                                    Button {

                                    } label: {
                                        Image("spwifiy.add.queue")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)

                                    Button {

                                    } label: {
                                        Image("spwifiy.more")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)
                                }
                            }
                            .foregroundStyle(.fgPrimary)
                            .padding()

                            Spacer()
                                .frame(height: 20)
                        }
                    }
                    .offset(y: -geom.frame(in: .global).minY / 3)
                }
                .frame(height: 400)

                Rectangle()
                    .foregroundStyle(.bgMain)
                    .frame(height: 1000)
            }
        }
        .task {
            await artistViewModel.updateArtistDetails()
        }
    }

}
