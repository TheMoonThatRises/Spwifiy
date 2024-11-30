//
//  PlaylistSongListElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI
import CachedAsyncImage

struct PlaylistSongListElement: View {

    var showFlags: Int

    @Binding var tracks: [Track]
    @Binding var savedTracks: [Bool]

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

        ScrollView {
            LazyVGrid(columns: columnFormat, alignment: .leading) {
                ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
//                ForEach(Array(zip(tracks, savedTracks).enumerated()), id: \.offset) { index, item in
                    Text(String(index + 1))

                    HStack {
                        CachedAsyncImage(url: track.album?.images?.first?.url, urlCache: .imageCache) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                        }
                        .scaledToFill()
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.title3)
                                .foregroundStyle(.fgPrimary)
                                .lineLimit(1)

                            Spacer()
                                .frame(height: 5)

                            Text(track.artists?.map { $0.name }.joined(separator: ", ") ?? "Unknown artists")
                                .lineLimit(1)
                        }
                    }

                    Text(track.album?.name ?? "Unknown album")
                        .lineLimit(2)

                    Text(track.durationMS?.humanReadable.description ?? "00:00")

                    Button {

                    } label: {
                        Image(false ? "spwifiy.like.fill" : "spwifiy.like")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(false ? .primary : .fgSecondary)
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
