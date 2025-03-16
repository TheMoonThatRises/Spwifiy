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
                               removeSong: nil,
                               selectedArtist: $selectedArtist)

                Spacer()
                    .frame(height: 40)

                HStack {
                    Text(currentView == .queueView ? "Next up:" : "Previously Played:")
                        .foregroundStyle(.fgPrimary)
                        .font(.satoshiBlack(16))

                    Spacer()

                    Button {
                        if currentView == .queueView {
                            avAudioPlayer.clearQueue()
                        } else {
                            avAudioPlayer.clearPrevQueue()
                        }
                    } label: {
                        Text("Clear")
                            .foregroundStyle(.fgPrimary)
                            .font(.satoshiLight(14))
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                }

                Spacer()
                    .frame(height: 20)

                List {
                    ForEach(currentView == .queueView
                            ? Array(avAudioPlayer.trackQueue.dropFirst(avAudioPlayer.playingIndex + 1))
                            : avAudioPlayer.previousQueue,
                            id: \.uri) { track in
                        TrackQueueView(track: track,
                                       removeSong: avAudioPlayer.removeSong(track:),
                                       selectedArtist: $selectedArtist)
                    }
                    .onMove { indices, newOffset in
                        if currentView == .queueView {
                            let adjustedIndices = IndexSet(indices.map { $0 + avAudioPlayer.playingIndex + 1 })
                            let adjustedNewOffset = newOffset + avAudioPlayer.playingIndex + 1

                            avAudioPlayer.trackQueue.move(fromOffsets: adjustedIndices,
                                                          toOffset: adjustedNewOffset)
                        }
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
    let removeSong: ((Track) -> Void)?

    @Binding var selectedArtist: Artist?

    var body: some View {
        HStack {
            CroppedCachedAsyncImage(url: track.album?.images?.first?.url,
                                    width: 50,
                                    height: 50,
                                    alignment: .center,
                                    clipShape: RoundedRectangle(cornerRadius: 5))

            HStack {
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

                Spacer()
            }
            .frame(width: 130)

            Spacer()

            if let removeSong = removeSong {
                Button {
                    removeSong(track)
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

}
