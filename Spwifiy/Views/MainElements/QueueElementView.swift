//
//  QueueElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/12/24.
//

import SwiftUI
import SpotifyWebAPI

struct QueueElementView: View {

    enum CurrentView: String, CaseIterable {
        case queueView = "Queue"
        case previousView = "Recent"
    }

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var selectedArtist: Artist?

    @State var currentView: CurrentView = .queueView

    var body: some View {
        VStack(alignment: .leading) {
            UnderlinedViewMenu(types: CurrentView.allCases,
                               currentOption: $currentView)

            if avAudioPlayer.trackQueue.count > 0 {
                TrackQueueView(track: avAudioPlayer.trackQueue[avAudioPlayer.playingIndex],
                               selectedArtist: $selectedArtist)

                Spacer()
                    .frame(height: 40)

                Text("Next up:")
                    .foregroundStyle(.fgPrimary)
                    .font(.satoshiBlack(16))

                Spacer()
                    .frame(height: 20)

                List {
                    ForEach(currentView == .queueView
                            ? avAudioPlayer.trackQueue
                        .suffix(avAudioPlayer.trackQueue.count - avAudioPlayer.playingIndex - 1)
                            : avAudioPlayer.previousQueue,
                            id: \.uri) { track in
                        TrackQueueView(track: track,
                                       selectedArtist: $selectedArtist)
                    }
                    .onMove { indices, newOffset in
                        avAudioPlayer.trackQueue.move(fromOffsets: indices,
                                                      toOffset: newOffset)
                    }
                }
            } else {
                Text("Play some songs to populate the queue")
                    .padding()
            }

            Spacer()
        }
        .padding()
        .frame(width: 300)
        .foregroundStyle(.fgSecondary)
    }

}

struct TrackQueueView: View {

    let track: Track

    @Binding var selectedArtist: Artist?

    var body: some View {
        HStack {
            CroppedCachedAsyncImage(url: track.album?.images?.first?.url,
                                    width: 50,
                                    height: 50,
                                    alignment: .center,
                                    clipShape: RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading) {
                Text(track.name)
                    .foregroundStyle(.fgPrimary)
                    .font(.satoshiCustom(nil, 14))

                Button {
                    selectedArtist = track.artists?.first
                } label: {
                    Text(track.artists?.description ?? "Artist")
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }
            .lineLimit(1)
            .frame(maxWidth: 150)
            .fixedSize()

            Spacer()

            Button {

            } label: {
                Image("spwifiy.close")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)
        }
    }

}
