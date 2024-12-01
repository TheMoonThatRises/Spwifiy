//
//  ArtistBannerElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import SwiftUI

struct ArtistBannerElement: View {

    var artistImageURL: URL?
    var artistName: String

    @Binding var backgroundImageURL: URL?
    @Binding var monthlyListeners: Int?

    @State var showArtistBannerInfo: Bool = true

    var body: some View {
        GeometryReader { geom in
            let minY = geom.frame(in: .global).minY

            ZStack {
                Group {
                    if let backgroundImageURL = backgroundImageURL {
                        CroppedCachedAsyncImage(url: backgroundImageURL,
                                                width: geom.size.width,
                                                height: 400,
                                                alignment: .top,
                                                clipShape: RoundedRectangle(cornerRadius: 5))
                    } else {
                        CroppedCachedAsyncImage(url: artistImageURL,
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
                            Text(artistName)
                                .font(.satoshiBlack(60))
                                .fontWeight(.black)
                                .foregroundStyle(.fgPrimary)

                            Spacer()
                                .frame(height: 25)

                            Text("\(monthlyListeners?.formatted() ?? ". . .") monthly listeners")
                                .font(.title3)
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
                .opacity(showArtistBannerInfo ? 1 : 0)
            }
            .offset(y: -(minY - 92) / 2)
            .onChange(of: minY) { newValue in
                withAnimation(.easeInOut) {
                    showArtistBannerInfo = -newValue < 50
                }
            }
        }
        .frame(height: 400)
    }

}
