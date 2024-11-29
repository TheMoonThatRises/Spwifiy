//
//  PlaylistTopElement.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistTopElement: View {

    var playlist: Playlist<PlaylistItems>

    @ObservedObject var selectedPlaylistViewModel: SelectedPlaylistViewModel

    var body: some View {
        Text(playlist.name)
            .font(.custom("Satoshi-Black", size: 40))
            .fontWeight(.black)
            .foregroundStyle(.fgPrimary)

        Spacer()
            .frame(height: 20)

        HStack {
            Text("By")
                .font(.callout)
                .foregroundStyle(.fgSecondary)

            Text(playlist.owner?.displayName ?? "unknown")
                .font(.callout)
                .foregroundStyle(.fgPrimary)

            Circle()
                .frame(width: 3, height: 3)
                .foregroundStyle(.fgSecondary)

            Text("\(playlist.items.total) songs")
                .font(.callout)
                .foregroundStyle(.fgSecondary)

            Circle()
                .frame(width: 3, height: 3)
                .foregroundStyle(.fgSecondary)

            if let duration = selectedPlaylistViewModel.totalDuration {
                Text("\(duration.hours) hr \(duration.minutes) min")
                    .font(.callout)
                    .foregroundStyle(.fgSecondary)
            }
        }

        Spacer()
            .frame(height: 20)

        HStack {
            Button {

            } label: {
                Image("spwifiy.play.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            Button {

            } label: {
                Image("spwifiy.shuffle")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            Button {

            } label: {
                Image("spwifiy.add")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            Button {

            } label: {
                Image("spwifiy.add.queue")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

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

            Group {
                HStack {
                    Button {
                        withAnimation {
                            selectedPlaylistViewModel.didSelectSearch.toggle()
                        }
                    } label: {
                        Image("spwifiy.search")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    if selectedPlaylistViewModel.didSelectSearch {
                        TextField(text: $selectedPlaylistViewModel.searchText) {
                            Text("Search")
                                .font(.title3)
                        }
                        .padding(.trailing, 10)
                    }
                }
            }
            .foregroundStyle(selectedPlaylistViewModel.didSelectSearch ? .fgPrimary : .fgSecondary)
            .frame(maxWidth: 300)
            .overlay {
                if selectedPlaylistViewModel.didSelectSearch {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.fgPrimary.opacity(0.1))
                        .allowsHitTesting(false)
                }
            }
        }
        .foregroundStyle(.fgSecondary)
    }

}
