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
        }
    }

}
