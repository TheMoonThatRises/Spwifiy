//
//  MainView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI
import SpotifyWebAPI
import AlertToast

struct MainView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel
    @ObservedObject var spotifyDataViewModel: SpotifyDataViewModel

    @ObservedObject var mainViewModel: MainViewModel

    @ObservedObject var spotifyCache: SpotifyCache

    @ObservedObject var avAudioPlayer: AVAudioPlayer

    @State var showIsVerifyingUser: Bool = true
    @State var showVerificationFailed: Bool = false
    @State var isVerifiedBetaTester: Bool? {
        didSet {
            showIsVerifyingUser = false
            showVerificationFailed = !(isVerifiedBetaTester ?? false)
        }
    }

    var body: some View {
        GeometryReader { geom in
            HStack {
                VStack {
                    SidebarElementView(mainViewModel: mainViewModel,
                                       collapsed: geom.size.width < 1020)

                    Spacer()
                }

                VStack {
                    HeadElementView(spotifyViewModel: spotifyViewModel,
                                    mainViewModel: mainViewModel,
                                    userProfile: $spotifyViewModel.userProfile,
                                    collapsed: geom.size.width < 1020)

                    Spacer()

                    Group {
                        switch mainViewModel.currentViewAnimated {
                        // default view
                        case .home:
                            HomeView(spotifyDataViewModel: spotifyDataViewModel,
                                     mainViewModel: mainViewModel)

                        // sidebar views
                        case .likedSongs:
                            LikedSongsView(spotifyCache: spotifyCache,
                                           selectedArtist: $mainViewModel.selectedArtist,
                                           selectedAlbum: $mainViewModel.selectedAlbum)

                        // layers deep abstracted view
                        case .selectedPlaylist:
                            if let selectedPlaylist = mainViewModel.selectedPlaylist {
                                SelectedPlaylistView(
                                    showFlags: PlaylistShowFlags.none,
                                    spotifyCache: spotifyCache,
                                    avAudioPlayer: avAudioPlayer,
                                    playlist: selectedPlaylist,
                                    selectedArtist: $mainViewModel.selectedArtist,
                                    selectedAlbum: $mainViewModel.selectedAlbum
                                )
                            } else {
                                Text("Unable to get selected playlist")
                                    .font(.title)
                            }
                        case .selectedArtist:
                            if let artist = mainViewModel.selectedArtist {
                                ArtistView(spotifyCache: spotifyCache, artist: artist)
                            } else {
                                Text("Unable to get selected artist")
                                    .font(.title)
                            }

                        // unimplemented views
                        default:
                            Text("Unknown error")
                                .font(.title)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.fgTertiary, lineWidth: 0.5)
                            .allowsHitTesting(false)
                    }

                    PlayingElementView(avAudioPlayer: avAudioPlayer,
                                       selectedArtist: $mainViewModel.selectedArtist,
                                       selectedAlbum: $mainViewModel.selectedAlbum)
                }
            }
            .padding()
        }
        .disabled(!(isVerifiedBetaTester ?? false))
        .toast(isPresenting: $showIsVerifyingUser, tapToDismiss: false) {
            AlertToast(type: .loading, title: "Verifying User")
        }
        .sheet(isPresented: $showVerificationFailed) {
            ClosedBetaErrorSheet()
        }
        .sheet(isPresented: $spotifyViewModel.isAuthenticating) {
            AttemptingReauthSheet()
        }
        .task {
            await spotifyViewModel.loadUserProfile()

            VerifyClosedBeta.shared.verifyUser(spotifyId: spotifyViewModel.userProfile?.id ?? "") { result in
                isVerifiedBetaTester = result
            }
        }
    }
}

struct ClosedBetaErrorSheet: View {
    var body: some View {
        VStack {
            Text("Spwifiy is currently in closed beta. Only invited people may particpate.")

            Text("If you believe this is incorrect, please double check your internet connection.")

            HStack {
                Spacer()

                Button {
                    exit(1)
                } label: {
                    Text("Quit app")
                }
            }
        }
        .padding()
    }
}

struct AttemptingReauthSheet: View {
    var body: some View {
        VStack {
            Text("Attempting to reauthorize Spwifiy client (spotify token unauthorized).")

            Text("Double check to make sure your system clock has not drifted.")

            HStack {
                Spacer()

                Button {
                    exit(1)
                } label: {
                    Text("Force quit")
                }
            }
        }
        .padding()
    }
}
