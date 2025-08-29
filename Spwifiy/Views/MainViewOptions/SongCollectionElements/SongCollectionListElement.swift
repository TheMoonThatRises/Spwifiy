//
//  SongCollectionListElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI

class CollectionShowFlags {
    static let none = 1 << 1
    static let showAlbum = 1 << 2
    static let largerSide = 1 << 3
    static let noSongListTitle = 1 << 4
}

struct SongCollectionListElement: View {

    var showFlags: Int
    var playingId: String?

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var tracks: [Track]
    @Binding var savedTracks: [Bool]

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    @State var hoverTrackId: String?

    private var showAlbumInfo: Bool {
        (showFlags & CollectionShowFlags.showAlbum) > 0
    }

    private var columnFormat: [GridItem] {
        var defaultColumn: [GridItem] = [
            .init(.fixed(30)),                              // index
            .init(.flexible()),                             // title and artist
            .init(.fixed(80)),                              // duration
            .init(.fixed(30))                               // like
        ]

        if showAlbumInfo {
            defaultColumn.insert(.init(.flexible()), at: 2) // album
        }

        return defaultColumn
    }

    var body: some View {
        if (showFlags & CollectionShowFlags.noSongListTitle) == 0 {
            LazyVGrid(columns: columnFormat, alignment: .leading) {
                Text("#")

                Text("Title")

                if showAlbumInfo {
                    Text("Album")
                }

                Text("Duration")

                Spacer()
            }

            Divider()
        }

        ScrollView {
            LazyVGrid(columns: columnFormat, alignment: .leading, spacing: 15) {
                ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
//              ForEach(Array(zip(tracks, savedTracks).enumerated()), id: \.offset) { index, item in
                    Group {
                        Group {
                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                                if hoverTrackId != nil && hoverTrackId == track.id {
                                    Button {
                                        if avAudioPlayer.currentPlayingTrack?.id == hoverTrackId {
                                            if avAudioPlayer.playerReady {
                                                avAudioPlayer.togglePlay()
                                            }
                                        } else {
                                            if playingId == avAudioPlayer.playingId {
                                                avAudioPlayer.goToQueueTrack(track: track, newQueue: tracks)
                                            } else {
                                                avAudioPlayer.updatePlayingList(newPlayingId: playingId,
                                                                                tracks: tracks,
                                                                                starting: track)
                                            }
                                        }
                                    } label: {
                                        Image(
                                            avAudioPlayer.isPlaying &&
                                            avAudioPlayer.currentPlayingTrack?.id == hoverTrackId
                                                ? "spwifiy.pause"
                                                : "spwifiy.play.simple"
                                        )
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(
                                            avAudioPlayer.currentPlayingTrack?.id == track.id && avAudioPlayer.isPlaying
                                            ? .sPrimary
                                            : .fgPrimary
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .cursorHover(.pointingHand)
                                } else {
                                    if avAudioPlayer.currentPlayingTrack?.id == track.id {
                                        Image("spwifiy.playing")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundStyle(avAudioPlayer.isPlaying ? .sPrimary : .fgSecondary)
                                    } else {
                                        Text(String(index + 1))
                                    }
                                }
                            }
                        }

                        HStack {
                            if showAlbumInfo {
                                CroppedCachedAsyncImage(url: track.album?.images?.first?.url,
                                                        width: 50,
                                                        height: 50,
                                                        alignment: .center,
                                                        clipShape: RoundedRectangle(cornerRadius: 5))
                            }

                            VStack(alignment: .leading) {
                                Text(track.name)
                                    .font(.title3)
                                    .foregroundStyle(
                                        avAudioPlayer.currentPlayingTrack?.id == track.id && avAudioPlayer.isPlaying
                                            ? .sPrimary
                                            : .fgPrimary
                                    )
                                    .lineLimit(1)

                                Spacer()
                                    .frame(height: 5)

                                Button {
                                    selectedArtist = track.artists?.first
                                } label: {
                                    HStack {
                                        if track.isExplicit {
                                            ExplicitSymbol()
                                        }

                                        Text(track.artists?.description ?? "Unknown artists")
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                                .cursorHover(.pointingHand)
                            }
                        }

                        if showAlbumInfo {
                            Button {
                                selectedAlbum = track.album
                            } label: {
                                Text(track.album?.name ?? "Unknown album")
                                    .lineLimit(2)
                            }
                            .buttonStyle(.plain)
                            .cursorHover(.pointingHand)
                        }

                        Text(track.durationMS?.humanReadable.description ?? "00:00")

                        Button {

                        } label: {
                            Image(false ? "spwifiy.like.fill" : "spwifiy.like")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(false ? .sPrimary : .fgSecondary)
                        }
                        .buttonStyle(.plain)
                        .cursorHover(.pointingHand)
                    }
                    .contentShape(.rect)
                    .onHover { isHovering in
                        hoverTrackId = isHovering ? track.id : nil
                    }
                    .contextMenu {
                        ContextView(track: track)
                    }
                    .disabled(track.isExplicit && !avAudioPlayer.playExplicit)
                }
            }
            .font(.callout)
            .foregroundStyle(.fgSecondary)
        }
    }

}
