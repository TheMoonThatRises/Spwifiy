//
//  LyricsView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/23/25.
//

import SwiftUI
import SpotifyWebAPI
import MediaPlayer

struct LyricsView: View {

    @ObservedObject var spotifyCache: SpotifyCache

    @Binding var currentTrack: Track?
    @Binding var currentPlayTime: Double

    let seek: (CMTime) -> Void

    @State var spotifyLyrics: SpotifyLyrics?

    var currentPlayTimeMS: Int {
        Int(currentPlayTime * 1000)
    }

    private let offset: Int = 500

    var body: some View {
        Group {
            if let spotifyLyrics {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(spotifyLyrics.lyrics.lines.enumeratedArray(), id: \.element.startTimeMs) { idx, line in
                            Button {
                                let seekTime = Double(line.startTimeMs) / 1000.0

                                seek(CMTime(seconds: seekTime,
                                            preferredTimescale: 100))
                                currentPlayTime = seekTime
                            } label: {
                                Text(line.words)
                                    .foregroundStyle(
                                        line.startTimeMs - offset <= currentPlayTimeMS && (
                                            spotifyLyrics.lyrics.lines.count <= idx + 1 ||
                                            spotifyLyrics.lyrics.lines[idx + 1].startTimeMs - offset > currentPlayTimeMS
                                        )
                                        ? .fgPrimary
                                        : .fgSecondary
                                    )
                            }
                            .cursorHover(.pointingHand)
                            .buttonStyle(.plain)

                            if line.startTimeMs != spotifyLyrics.lyrics.lines.last?.startTimeMs {
                                Spacer()
                                    .frame(height: 40)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                Text("No lyrics found")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .font(.satoshiBlack(40))
        .onChange(of: currentTrack) { _ in
            Task {
                if let songId = currentTrack?.id {
                    spotifyLyrics = try? await spotifyCache.fetchLyrics(songId: songId)
                }
            }
        }
        .task {
            if let songId = currentTrack?.id {
                spotifyLyrics = try? await spotifyCache.fetchLyrics(songId: songId)
            }
        }
    }

}
