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

    @Binding var extendedLogin: SpotifyAuthManager.AuthStatus

    @Binding var currentTrack: Track?
    @Binding var currentPlayTime: Double

    let seek: (CMTime) -> Void

    @State var spotifyLyrics: SpotifyLyrics?
    @State var currentLineIdx: Int?
    @State var noCacheLyrics: Bool = false

    var currentPlayTimeMS: Int {
        Int(currentPlayTime * 1000)
    }

    private let offset: Int = 500

    var body: some View {
        Group {
            if extendedLogin != .success {
                VStack {
                    Text("Extended Spotify login required for lyric access")
                    Text("This can be enabled in settings")
                }
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let spotifyLyrics {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(spotifyLyrics.lyrics.lines.enumeratedArray(),
                                    id: \.element.startTimeMs) { idx, line in
                                Button {
                                    let seekTime = Double(line.startTimeMs) / 1000.0

                                    seek(CMTime(seconds: seekTime,
                                                preferredTimescale: 100))
                                    currentPlayTime = seekTime
                                } label: {
                                    Text(line.words)
                                        .foregroundStyle(currentLineIdx == idx ? .fgPrimary : .fgSecondary)
                                }
                                .cursorHover(.pointingHand)
                                .buttonStyle(.plain)
                                .id(idx)

                                if line.startTimeMs != spotifyLyrics.lyrics.lines.last?.startTimeMs {
                                    Spacer()
                                        .frame(height: 40)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .onChange(of: currentPlayTimeMS) { newTime in
                        let lines = spotifyLyrics.lyrics.lines

                        if let newIdx = lines.firstIndex(where: { line in
                            let nextStart = lines[safe: lines.firstIndex(of: line)! + 1]?.startTimeMs ?? Int.max
                            return line.startTimeMs - offset <= newTime && nextStart - offset > newTime
                        }) {
                            if newIdx != currentLineIdx {
                                withAnimation(.defaultAnimation) {
                                    currentLineIdx = newIdx

                                    proxy.scrollTo(currentLineIdx, anchor: .center)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Text("No lyrics found")

                    Spacer()
                        .frame(height: 20)

                    Button {
                        noCacheLyrics = true
                        currentTrack = currentTrack
                    } label: {
                        Text("Force reload lyrics")
                            .padding()
                    }
                }
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .font(.satoshiBlack(40))
        .onChange(of: currentTrack) { _ in
            currentLineIdx = nil

            Task {
                if let songId = currentTrack?.id {
                    spotifyLyrics = try? await spotifyCache.fetchLyrics(songId: songId, cache: noCacheLyrics)
                }

                noCacheLyrics = false
            }
        }
        .task {
            if let songId = currentTrack?.id {
                spotifyLyrics = try? await spotifyCache.fetchLyrics(songId: songId)
            }
        }
    }

}
