//
//  ArtistHomeView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/17/25.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistHomeView: View {

    @ObservedObject var artistViewModel: ArtistViewModel

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @State var showExtendedTop: Bool = false {
        didSet {
            topTracks = Array(
                artistViewModel.topTracks[
                    0..<min(showExtendedTop ? 10 : 5, artistViewModel.topTracks.count)
                ]
            )
        }
    }
    @State var topTracks: [Track] = []

    private var showFlags: Int  {
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
                                          tracks: $topTracks,
                                          savedTracks: .constant([]),
                                          selectedArtist: .constant(nil),
                                          selectedAlbum: .constant(nil))

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
        .onChange(of: artistViewModel.topTracks) { _ in
            showExtendedTop = false
        }
    }

}
