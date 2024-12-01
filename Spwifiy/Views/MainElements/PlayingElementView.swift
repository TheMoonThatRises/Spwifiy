//
//  PlayingElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlayingElementView: View {

    @StateObject var playingViewModel: PlayingViewModel

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    init(playingTrack: Binding<Track?>,
         selectedArtist: Binding<Artist?>,
         selectedAlbum: Binding<Album?>) {
        self._playingViewModel = StateObject(wrappedValue: PlayingViewModel(playingTrack: playingTrack))
        self._selectedArtist = selectedArtist
        self._selectedAlbum = selectedAlbum
    }

    var body: some View {
        HStack {
            Group {
                Button {

                } label: {
                    Image("spwifiy.pause.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.previous")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.next")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                DotButton(toggle: $playingViewModel.isShuffled,
                          image: Image("spwifiy.shuffle"))

                DotButton(toggle: $playingViewModel.isLooping,
                          image: Image("spwifiy.loop"))

                Text(playingViewModel.currentTime?.humanReadable.description ?? "-:-")

                ProgressView(value: playingViewModel.progress ?? 0)
                    .frame(minWidth: 100)

                Text(playingViewModel.totalTime?.humanReadable.description ?? "-:-")

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
                CroppedCachedAsyncImage(url: playingViewModel.playingTrack?.album?.images?.first?.url,
                                        width: 40,
                                        height: 40,
                                        alignment: .center,
                                        clipShape: RoundedRectangle(cornerRadius: 5))
                    .foregroundStyle(.fgSecondary)

                VStack(alignment: .leading) {
                    Text(playingViewModel.playingTrack?.name ?? "Title")
                        .foregroundStyle(.fgPrimary)

                    Button {
                        selectedArtist = playingViewModel.playingTrack?.artists?.first
                    } label: {
                        Text(playingViewModel.playingTrack?.artists?.description ?? "Artist")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {
                        selectedAlbum = playingViewModel.playingTrack?.album
                    } label: {
                        Text("Album")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                }
            }
            .lineLimit(1)

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
