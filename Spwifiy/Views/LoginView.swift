//
//  LoginView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel

    var body: some View {
        VStack {
            Spacer()

            Text("Attempting to authorize...")
                .font(.title)

            Spacer()

            Text("Click the URL below if an authorization window does not appear")
                .font(.title)
            Link(destination: spotifyViewModel.authorizationURL) {
                Text(spotifyViewModel.authorizationURL.absoluteString)
                    .font(.title)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if spotifyViewModel.useURLAuth {
                NSWorkspace.shared.open(spotifyViewModel.authorizationURL)
            }
        }
    }
}
