//
//  SelectedPlaylistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import CachedAsyncImage

struct SelectedPlaylistView: View {

    @ObservedObject var selectedPlaylistViewModel: SelectedPlaylistViewModel

    var body: some View {
        if let playlist = selectedPlaylistViewModel.playlistDetails {
            HStack {
                VStack(alignment: .leading) {
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

                    Spacer()
                        .frame(height: 20)

                    Spacer()
                }
                .padding()

                Spacer()

                VStack {
                    CachedAsyncImage(url: playlist.images.first?.url, urlCache: .imageCache) { image in
                        image
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .task {
                                let id = playlist.images.first?.url.absoluteString ?? ""
                                let dominantColor = image.calculateDominantColor(id: id)
                                selectedPlaylistViewModel.dominantColor = dominantColor ?? .fgPrimary
                            }
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                    }
                    .frame(width: 260, height: 260)

                    Spacer()
                }
                .padding()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [selectedPlaylistViewModel.dominantColor.opacity(0.5),
                                                           .bgMain]),
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            Text("Fetching playlist...")
                .task {
                    selectedPlaylistViewModel.fetchPlaylistDetails()
                }
        }
    }

}
