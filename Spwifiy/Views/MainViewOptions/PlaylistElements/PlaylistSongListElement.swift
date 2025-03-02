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

    var selectedSong: (Track) -> Void

    @Binding var tracks: [Track]
    @Binding var savedTracks: [Bool]

    @Binding var selectedArtist: Artist?
    @Binding var selectedAlbum: Album?

    @State var isHoveringPlay: [Bool]

    init(showFlags: Int,
         selectedSong: @escaping (Track) -> Void,
         tracks: Binding<[Track]>,
         savedTracks: Binding<[Bool]>,
         selectedArtist: Binding<Artist?>,
         selectedAlbum: Binding<Album?>) {
        self.showFlags = showFlags
        self.selectedSong = selectedSong
        self._tracks = tracks
        self._savedTracks = savedTracks
        self._selectedArtist = selectedArtist
        self._selectedAlbum = selectedAlbum

        self.isHoveringPlay = [Bool](repeating: false, count: tracks.count)
    }

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
                    VStack(alignment: .center) {
                        if index < isHoveringPlay.count && isHoveringPlay[index] {
                            Button {
                                selectedSong(track)
                            } label: {
                                Image("spwifiy.play.simple")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .cursorHover(.pointingHand)
                        } else {
                            Text(String(index + 1))
                        }
                    }
                    .onHover { hover in
                        if index < isHoveringPlay.count {
                            isHoveringPlay[index] = hover
                        }
                    }

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
        .onChange(of: tracks) { newValue in
            isHoveringPlay = [Bool](repeating: false, count: newValue.count)
        }
    }

}
