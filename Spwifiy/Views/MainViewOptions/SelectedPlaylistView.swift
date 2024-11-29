//
//  SelectedPlaylistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import CachedAsyncImage
import SpotifyWebAPI

class PlaylistShowFlags {
    static let album = 1 << 1
    static let sideBar = 1 << 2
    static let largerSide = 1 << 3
    static let topView = 1 << 4
}

struct SelectedPlaylistView: View {

    var showFlags: Int

    @ObservedObject var selectedPlaylistViewModel: SelectedPlaylistViewModel

    var body: some View {
        Group {
            if let playlist = selectedPlaylistViewModel.playlistDetails {
                HStack {
                    VStack(alignment: .leading) {
                        if (showFlags & PlaylistShowFlags.topView) > 0 {
                            PlaylistTopElement(playlist: playlist,
                                               selectedPlaylistViewModel: selectedPlaylistViewModel)

                            Spacer()
                                .frame(height: 20)
                        }

                        PlaylistSongListElement(showFlags: showFlags,
                                                selectedPlaylistViewModel: selectedPlaylistViewModel)

                        Spacer()
                    }
                    .padding()

                    if (showFlags & PlaylistShowFlags.sideBar) > 0 {
                        Spacer()

                        PlaylistSidebarElement(playlist: playlist,
                                               showFlags: showFlags,
                                               selectedPlaylistViewModel: selectedPlaylistViewModel)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [selectedPlaylistViewModel.dominantColor.opacity(0.8),
                                                               .bgMain]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Text("Fetching playlist...")
                    .font(.title)
            }
        }
        .task {
            await selectedPlaylistViewModel.updatePlaylistInfo()
        }
    }
}
