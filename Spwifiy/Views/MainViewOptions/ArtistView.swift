//
//  ArtistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import CachedAsyncImage
import SpotifyWebAPI

struct ArtistView: View {

    @StateObject var artistViewModel: ArtistViewModel

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self._artistViewModel = StateObject(
            wrappedValue: ArtistViewModel(spotifyCache: spotifyCache, artist: artist)
        )
    }

    var body: some View {
        ScrollView {
            VStack {
                ArtistBannerElement(artistImageURL: artistViewModel.artist.images?.first?.url,
                                    artistName: artistViewModel.artist.name,
                                    backgroundImageURL: $artistViewModel.backgroundImageURL,
                                    monthlyListeners: $artistViewModel.monthlyListeners)

                VStack {
                    HStack {
                        Text("Home")

                        ExpandSearch(searchText: $artistViewModel.searchText)

                        Spacer()
                    }
                    .font(.title3)
                    .padding(5)

                    Divider()

                    Rectangle()
                        .frame(height: 600)
                        .foregroundStyle(.clear)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.bgMain)
            }
        }
        .task {
            await artistViewModel.updateArtistDetails()
        }
    }

}
