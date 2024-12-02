//
//  PlayingElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlayingElementView: View {

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    var body: some View {
        HStack {
            Group {
                Button {
                    avAudioPlayer.togglePlay()
                } label: {
                    Image(avAudioPlayer.isPlaying ? "spwifiy.pause.fill" : "spwifiy.play.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {
                    avAudioPlayer.prevSong()
                } label: {
                    Image("spwifiy.previous")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {
                    avAudioPlayer.nextSong()
                } label: {
                    Image("spwifiy.next")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                DotButton(toggle: $avAudioPlayer.isShuffled,
                          image: Image("spwifiy.shuffle"))

                DotButton(toggle: $avAudioPlayer.isLooping,
                          image: Image("spwifiy.loop"))

                Group {
                    if avAudioPlayer.isScrubbing {
                        Slider(value: $avAudioPlayer.playProgress, in: 0...1) {

                        } minimumValueLabel: {
                            Text(Int(avAudioPlayer.currentPlayTime * 1000).humanReadable.description)
                        } maximumValueLabel: {
                            Text(Int(avAudioPlayer.totalRunTime * 1000).humanReadable.description)
                        } onEditingChanged: { scrubbing in
                            if !scrubbing {
                                avAudioPlayer.isScrubbing = false
                            }
                        }
                        .frame(minWidth: 100)
                    } else {
                        Button {
                            avAudioPlayer.isScrubbing = true
                        } label: {
                            Text(Int(avAudioPlayer.currentPlayTime * 1000).humanReadable.description)

                            ProgressView(value: avAudioPlayer.playProgress)
                                .frame(minWidth: 100)

                            Text(Int(avAudioPlayer.totalRunTime * 1000).humanReadable.description)
                        }
                        .buttonStyle(.plain)
                        .cursorHover(.pointingHand)
                    }
                }

                Button {

                } label: {
                    Image("spwifiy.volume")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }

            Group {
                CroppedCachedAsyncImage(url: avAudioPlayer.currentPlayingTrack?.album?.images?.first?.url,
                                        width: 40,
                                        height: 40,
                                        alignment: .center,
                                        clipShape: RoundedRectangle(cornerRadius: 5))
                    .foregroundStyle(.fgSecondary)

                VStack(alignment: .leading) {
                    Text(avAudioPlayer.currentPlayingTrack?.name ?? "Title")
                        .foregroundStyle(.fgPrimary)

                    Button {
                        selectedArtist = avAudioPlayer.currentPlayingTrack?.artists?.first
                    } label: {
                        Text(avAudioPlayer.currentPlayingTrack?.artists?.description ?? "Artist")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {
                        selectedAlbum = avAudioPlayer.currentPlayingTrack?.album
                    } label: {
                        Text(avAudioPlayer.currentPlayingTrack?.album?.name ?? "Album")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: 80)
            .fixedSize()

            Spacer()

            Group {
                Button {

                } label: {
                    Image("spwifiy.like")
                        .resizable()
                        .frame(width: 40, height: 40)
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
                    Image("spwifiy.lyrics")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.queue")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }
        }
        .foregroundStyle(.fgSecondary)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(.fgSecondary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
