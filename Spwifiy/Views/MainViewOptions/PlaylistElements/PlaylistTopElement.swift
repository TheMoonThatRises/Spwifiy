//
//  PlaylistTopElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistTopElement: View {

    @Binding var playlist: Playlist<PlaylistItems>?
    @Binding var album: Album?

    @ObservedObject var avAudioPlayer: AVAudioPlayer
    @Binding var tracks: [Track]

    @Binding var totalDuration: HumanFormat?
    @Binding var searchText: String

    var body: some View {
        Text(playlist?.name ?? album?.name ?? "Unknown")
            .font(.satoshiBlack(40))
            .fontWeight(.black)
            .foregroundStyle(.fgPrimary)

        Spacer()
            .frame(height: 20)

        HStack {
            Text("By")
                .font(.callout)
                .foregroundStyle(.fgSecondary)

            Text(playlist?.owner?.displayName ?? album?.artists?.first?.name ?? "Unknown")
                .font(.callout)
                .foregroundStyle(.fgPrimary)

            Circle()
                .frame(width: 3, height: 3)
                .foregroundStyle(.fgSecondary)

            Text("\(playlist?.items.total ?? album?.totalTracks ?? 0) songs")
                .font(.callout)
                .foregroundStyle(.fgSecondary)

            Circle()
                .frame(width: 3, height: 3)
                .foregroundStyle(.fgSecondary)

            if let duration = totalDuration {
                Text("\(duration.hours + duration.days * 24) hr \(duration.minutes) min")
                    .font(.callout)
                    .foregroundStyle(.fgSecondary)
            }
        }

        Spacer()
            .frame(height: 20)

        HStack {
            Button {
                avAudioPlayer.removeAllSongs()

                avAudioPlayer.addBulkSongs(
                    tracks: avAudioPlayer.isShuffled ? tracks.shuffled() : tracks
                )

                avAudioPlayer.playingId = playlist?.id
            } label: {
                Group {
                    if tracks.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Image(
                            avAudioPlayer.playingId == playlist?.id &&
                            avAudioPlayer.isPlaying ? "spwifiy.pause.fill"  : "spwifiy.play.fill"
                        )
                        .resizable()
                    }
                }
                .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)
            .disabled(tracks.isEmpty)

            DotButton(toggle: $avAudioPlayer.isShuffled,
                      image: Image("spwifiy.shuffle"))

            Button {

            } label: {
                Image("spwifiy.add")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            Button {
                avAudioPlayer.addBulkSongs(
                    tracks: avAudioPlayer.isShuffled ? tracks.shuffled() : tracks
                )
            } label: {
                Image("spwifiy.add.queue")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)
            .disabled(tracks.isEmpty)

            Button {

            } label: {
                Image("spwifiy.download")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            Button {

            } label: {
                Image("spwifiy.share")
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

            Spacer()

            ExpandSearch(searchText: $searchText)
        }
        .foregroundStyle(.fgSecondary)
    }

}
