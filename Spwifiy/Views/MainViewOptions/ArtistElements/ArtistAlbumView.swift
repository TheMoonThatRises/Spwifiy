//
//  ArtistAlbumView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistAlbumView: View {

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @Binding var filteredAlbums: [Album]
    @Binding var selectedAlbum: Album?

    @Binding var displayType: DisplayType

    var body: some View {
        ScrollView {
            if filteredAlbums.isEmpty {
                Text("No discography found")
            } else {
                if displayType == .list {
                    ArtistAlbumListView(filteredAlbums: $filteredAlbums,
                                        selectedAlbum: $selectedAlbum,
                                        avAudioPlayer: avAudioPlayer)
                } else {
                    ArtistAlbumGridView(filteredAlbums: $filteredAlbums,
                                        selectedAlbum: $selectedAlbum)
                }
            }
        }
    }

}

struct ArtistAlbumGridView: View {

    @Binding var filteredAlbums: [Album]
    @Binding var selectedAlbum: Album?

    let columns: [GridItem] = [
        .init(.adaptive(minimum: 170))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(filteredAlbums, id: \.id) { album in
                Button {
                    selectedAlbum = album
                } label: {
                    AlbumItemView(album: album, subtext: .year)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
                .id(album.id)
            }
        }
    }

}

struct ArtistAlbumListView: View {

    @Binding var filteredAlbums: [Album]
    @Binding var selectedAlbum: Album?

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    var duration: (Album) -> HumanFormat? {
        { album in
            album.tracks?.items
                .map { $0.durationMS ?? 0 }
                .reduce(0, +)
                .humanReadable
        }
    }

    var body: some View {
        LazyVStack {
            ForEach(filteredAlbums, id: \.id) { album in
                Button {
                    selectedAlbum = album
                } label: {
                    HStack {
                        AlbumItemView(album: album, imageOnly: true)
                            .contentShape(.rect)
                            .padding()

                        VStack(alignment: .leading) {
                            Text(album.name)
                                .font(.satoshiBlack(20))
                                .fontWeight(.black)
                                .foregroundStyle(.fgPrimary)

                            HStack {
                                Text(album.releaseDate?.formatted(.dateTime.year()) ?? "Unknown year")

                                Circle()
                                    .frame(width: 3, height: 3)

                                Text("\(album.totalTracks ?? 0) songs")

                                if let duration = duration(album) {
                                    Circle()
                                        .frame(width: 3, height: 3)

                                    Text("\(duration.hours + duration.days * 24) hr \(duration.minutes) min")
                                }
                            }
                            .font(.caption)

                            //                    HStack {
                            //                        Button {
                            //                            if avAudioPlayer.playingId == album.id {
                            //                                avAudioPlayer.togglePlay()
                            //                            } else {
                            //                                avAudioPlayer.updatePlayingList(newPlayingId: album.id,
                            //                                                                tracks: album.tracks?.items ?? [])
                            //                            }
                            //                        } label: {
                            //                            Image(
                            //                                avAudioPlayer.playingId == album.id &&
                            //                                avAudioPlayer.isPlaying ? "spwifiy.pause.fill"  : "spwifiy.play.fill"
                            //                            )
                            //                            .resizable()
                            //                            .overlay {
                            //                                if album.tracks?.items.isEmpty ?? true {
                            //                                    ProgressView()
                            //                                        .progressViewStyle(.circular)
                            //                                }
                            //                            }
                            //                            .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //
                            //                        DotButton(toggle: $avAudioPlayer.isShuffled,
                            //                                  image: Image("spwifiy.shuffle"))
                            //
                            //                        Button {
                            //
                            //                        } label: {
                            //                            Image("spwifiy.add")
                            //                                .resizable()
                            //                                .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //
                            //                        Button {
                            //
                            //                        } label: {
                            //                            Image("spwifiy.add.queue")
                            //                                .resizable()
                            //                                .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //                        Button {
                            //
                            //                        } label: {
                            //                            Image("spwifiy.download")
                            //                                .resizable()
                            //                                .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //
                            //                        Button {
                            //
                            //                        } label: {
                            //                            Image("spwifiy.share")
                            //                                .resizable()
                            //                                .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //
                            //                        Button {
                            //
                            //                        } label: {
                            //                            Image("spwifiy.more")
                            //                                .resizable()
                            //                                .frame(width: 40, height: 40)
                            //                        }
                            //                        .buttonStyle(.plain)
                            //                        .cursorHover(.pointingHand)
                            //                    }
                        }

                        Spacer()

                        Image("spwifiy.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .foregroundStyle(.fgSecondary)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }
        }
    }

}
