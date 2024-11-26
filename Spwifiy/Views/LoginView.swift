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

            Text("Attemptimg to authorize...")

            Spacer()

            Text("Click the URL below if an authorization window does not appear")
            Link(destination: spotifyViewModel.authorizationURL) {
                Text(spotifyViewModel.authorizationURL.absoluteString)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: spotifyViewModel.useURLAuth) { value in
            if value {
                NSWorkspace.shared.open(spotifyViewModel.authorizationURL)
            }
        }
    }
}
