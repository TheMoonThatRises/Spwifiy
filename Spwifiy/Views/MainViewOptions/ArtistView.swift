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

    @Binding var selectedAlbum: Album?

    @State var currentView: CurrentView = .homeView

    init(spotifyCache: SpotifyCache,
         artist: Artist,
         avAudioPlayer: AVAudioPlayer,
         selectedAlbum: Binding<Album?>) {
        self._artistViewModel = StateObject(
            wrappedValue: ArtistViewModel(spotifyCache: spotifyCache, artist: artist)
        )
        self.avAudioPlayer = avAudioPlayer
        self._selectedAlbum = selectedAlbum
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

                        Spacer()

                        if [.albumView, .singlesEpView].contains(currentView) {
                            NavButton(currentButton: .list, currentView: $artistViewModel.displayType) {

                            } label: {
                                Image("spwifiy.list")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .toButton()

                            NavButton(currentButton: .grid, currentView: $artistViewModel.displayType) {

                            } label: {
                                Image("spwifiy.grid")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .toButton()
                        }

                        ExpandSearch(searchText: $artistViewModel.searchText)
                    }
                    .font(.title3)
                    .padding(5)

                    Group {
                        switch currentView {
                        case .homeView:
                            ArtistHomeView(avAudioPlayer: avAudioPlayer,
                                           topTracks: $artistViewModel.topTracks,
                                           selectedAlbum: $selectedAlbum)
                        case .albumView:
                            ArtistAlbumView(avAudioPlayer: avAudioPlayer,
                                            filteredAlbums: $artistViewModel.filteredAlbums,
                                            selectedAlbum: $selectedAlbum,
                                            displayType: $artistViewModel.displayType)
                            .onChange(of: artistViewModel.searchText) { _ in
                                artistViewModel.onAlbumFilterChange()
                            }
                        case .singlesEpView:
                            ArtistAlbumView(avAudioPlayer: avAudioPlayer,
                                            filteredAlbums: $artistViewModel.filteredSingleEp,
                                            selectedAlbum: $selectedAlbum,
                                            displayType: $artistViewModel.displayType)
                            .onChange(of: artistViewModel.searchText) { _ in
                                artistViewModel.onSingleEpFilterChange()
                            }
//                        case .merchView:
//                        case .aboutView:
                        default:
                            Text("Unknown error")
                        }
                    }
                    .onChange(of: artistViewModel.albums) { _ in
                        artistViewModel.updateAlbumsFilters()
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
