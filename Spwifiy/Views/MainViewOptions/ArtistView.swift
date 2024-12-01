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
        VStack {
            ZStack {
                if let backgroundImageURL = artistViewModel.backgroundImageURL {
                    CroppedCachedAsyncImage(url: backgroundImageURL,
                                            maxWidth: .infinity,
                                            maxHeight: 400,
                                            alignment: .top,
                                            clipShape: RoundedRectangle(cornerRadius: 5))
                } else {
                    CroppedCachedAsyncImage(url: artistViewModel.artist.images?.first?.url,
                                            maxWidth: .infinity,
                                            maxHeight: 400,
                                            alignment: .center,
                                            clipShape: RoundedRectangle(cornerRadius: 5))
                }
            }

            Spacer()
        }
        .task {
            await artistViewModel.updateArtistDetails()
        }
    }

}
