//
//  PlaylistSongListElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistSongListElement: View {

    var showFlags: Int

    @Binding var tracks: [Track]
    @Binding var savedTracks: [Bool]

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    private var columnFormat: [GridItem] {
        var defaultColumn: [GridItem] = [
            .init(.flexible(maximum: 40)),        // index
            .init(.flexible(maximum: .infinity)), // title and artist
            .init(.flexible(maximum: 80)),        // duration
            .init(.flexible(maximum: 40))         // like
        ]

        if (showFlags & PlaylistShowFlags.album) == 0 {
            defaultColumn.insert(.init(.flexible()), at: 2) // album
        }

        return defaultColumn
    }

    var body: some View {
        if (showFlags & PlaylistShowFlags.noSongListTitle) == 0 {
            LazyVGrid(columns: columnFormat, alignment: .leading) {
                Text("#")

                Text("Title")

                if (showFlags & PlaylistShowFlags.album) == 0 {
                    Text("Album")
                }

                Text("Duration")

                Spacer()
            }

            Divider()
        }

        ScrollView {
            LazyVGrid(columns: columnFormat, alignment: .leading) {
                ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
//                ForEach(Array(zip(tracks, savedTracks).enumerated()), id: \.offset) { index, item in
                    Text(String(index + 1))

                    HStack {
                        CroppedCachedAsyncImage(url: track.album?.images?.first?.url,
                                                width: 50,
                                                height: 50,
                                                alignment: .center,
                                                clipShape: RoundedRectangle(cornerRadius: 5))

                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.title3)
                                .foregroundStyle(.fgPrimary)
                                .lineLimit(1)

                            Spacer()
                                .frame(height: 5)

                            Button {
                                selectedArtist = track.artists?.first
                            } label: {
                                Text(track.artists?.description ?? "Unknown artists")
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                            .cursorHover(.pointingHand)
                        }
                    }

                    Button {
                        selectedAlbum = track.album
                    } label: {
                        Text(track.album?.name ?? "Unknown album")
                            .lineLimit(2)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

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
            }
            .font(.callout)
            .foregroundStyle(.fgSecondary)
        }
    }

}
