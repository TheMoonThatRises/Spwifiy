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
    @ObservedObject var mainViewModel: MainViewModel

    @Binding var showQueueView: Bool

    @State var showVolumeSlider: Bool = false
    @State var isInteractingVolume: Bool = false

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

                CustomSlider(value: $avAudioPlayer.currentPlayTime,
                             maxValue: $avAudioPlayer.totalRunTime,
                             isInteracting: $avAudioPlayer.isScrubbing) { value in
                    Text(Int(value * 1000).humanReadable.description)
                        .frame(width: 50)
                } maxLabel: { maxValue in
                    Text(Int(maxValue * 1000).humanReadable.description)
                        .frame(width: 50)
                }
                .frame(minWidth: 100)

                Button {
                    showVolumeSlider.toggle()
                } label: {
                    Image("spwifiy.volume")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
                .popover(isPresented: $showVolumeSlider) {
                    ZStack {
                        Color.bgPrimary
                            .scaleEffect(1.5)

                        VStack {
                            Text("Volume: \(Int(avAudioPlayer.volume * 100))%")
                                .font(.satoshiBlack(14))

                            CustomSlider<Text>(value: $avAudioPlayer.volume,
                                               maxValue: .constant(1.0),
                                               isInteracting: $isInteractingVolume)
                        }
                        .frame(width: 150)
                        .padding(20)
                    }
                }
            }

            Group {
                CroppedCachedAsyncImage(url: avAudioPlayer.currentPlayingTrack?.album?.images?.first?.url,
                                        width: 40,
                                        height: 40,
                                        alignment: .center,
                                        clipShape: RoundedRectangle(cornerRadius: 5))
                    .foregroundStyle(.fgSecondary)

                VStack(alignment: .leading, spacing: 0) {
                    Text(avAudioPlayer.currentPlayingTrack?.name ?? "Title")
                        .foregroundStyle(.fgPrimary)

                    Button {
                        mainViewModel.selectedArtist = avAudioPlayer.currentPlayingTrack?.artists?.first
                    } label: {
                        HStack {
                            if avAudioPlayer.currentPlayingTrack?.isExplicit ?? false {
                                ExplicitSymbol()
                            }

                            Text(avAudioPlayer.currentPlayingTrack?.artists?.description ?? "Artist")
                        }
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {
                        mainViewModel.selectedAlbum = avAudioPlayer.currentPlayingTrack?.album
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
                    if mainViewModel.currentView == .lyrics {
                        mainViewModel.navToView(item: mainViewModel.navigationStack[1])
                    } else {
                        mainViewModel.currentView = .lyrics
                    }
                } label: {
                    Image("spwifiy.lyrics")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(mainViewModel.currentView == .lyrics ? .fgPrimary : .fgSecondary)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {
                    withAnimation(.defaultAnimation) {
                        showQueueView.toggle()
                    }
                } label: {
                    Image("spwifiy.queue")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(showQueueView ? .fgPrimary : .fgSecondary)
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
