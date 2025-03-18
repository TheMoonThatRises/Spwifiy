//
//  ArtistView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistView: View {

    enum CurrentView: String, CaseIterable {
        case homeView = "Home"
        case albumView = "Albums"
        case singlesEpView = "Singles and EPs"
        case merchView = "Merch"
        case aboutView = "About"
    }

    @StateObject var artistViewModel: ArtistViewModel

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @State var currentView: CurrentView = .homeView

    init(spotifyCache: SpotifyCache, artist: Artist, avAudioPlayer: AVAudioPlayer) {
        self._artistViewModel = StateObject(
            wrappedValue: ArtistViewModel(spotifyCache: spotifyCache, artist: artist)
        )
        self.avAudioPlayer = avAudioPlayer
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
                        UnderlinedViewMenu(types: CurrentView.allCases,
                                           currentOption: $currentView)

                        ExpandSearch(searchText: $artistViewModel.searchText)

                        Spacer()
                    }
                    .font(.title3)
                    .padding(5)

                    Group {
                        switch currentView {
                        case .homeView:
                            ArtistHomeView(artistViewModel: artistViewModel,
                                           avAudioPlayer: avAudioPlayer)
//                        case .albumView:
//                        case .singlesEpView:
//                        case .merchView:
//                        case .aboutView:
                        default:
                            Text("Unknown error")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
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
