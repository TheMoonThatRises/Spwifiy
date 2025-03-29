//
//  ArtistHomeView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/17/25.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistHomeView: View {

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var topTracks: [Track]

    @Binding var selectedAlbum: Album?

    @State var showExtendedTop: Bool = false {
        didSet {
            withAnimation(.defaultAnimation) {
                displayTopTracks = Array(
                    topTracks[
                        0..<min(showExtendedTop ? 10 : 5, topTracks.count)
                    ]
                )
            }
        }
    }
    @State var displayTopTracks: [Track] = []

    private var showFlags: Int {
        CollectionShowFlags.noSongListTitle | CollectionShowFlags.showAlbum
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Popular")
                    .foregroundStyle(.fgPrimary)
                    .font(.title)
                    .bold()

                Spacer()
                    .frame(height: 20)

                SongCollectionListElement(showFlags: showFlags,
                                          avAudioPlayer: avAudioPlayer,
                                          tracks: $displayTopTracks,
                                          savedTracks: .constant([]),
                                          selectedArtist: .constant(nil),
                                          selectedAlbum: $selectedAlbum)

                Spacer()
                    .frame(height: 20)

                Button {
                    showExtendedTop.toggle()
                } label: {
                    Text(showExtendedTop ? "Show less" : "Show more")
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }

            Spacer()

            Spacer()
                .frame(width: 20)
        }
        .onChange(of: topTracks) { _ in
            showExtendedTop = false
        }
        .onAppear {
            showExtendedTop = false
        }
    }

}
