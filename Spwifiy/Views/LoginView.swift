//
//  LoginView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var spotifyViewModel: SpotifyViewModel

    @State var getClientId: Bool = false
    @State var clientId: String
    @State var tmpClientId: String = ""

    var body: some View {
        VStack {
            Spacer()

            Text("Attempting to authorize...")
                .font(.title)

            Spacer()

            Button {
                getClientId = true
            } label: {
                Text("Set client id: \(clientId)")
            }

            Spacer()

            if let authorizationURL = spotifyViewModel.authorizationURL, !clientId.isEmpty {
                Text("Click the URL below if an authorization window does not appear")
                    .font(.title)
                Link(destination: authorizationURL) {
                    Text(authorizationURL.absoluteString)
                        .font(.title)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if clientId.isEmpty {
                getClientId = true
            } else {
                launchAuthWebpage()
            }
        }
        .alert("Retrieve client id", isPresented: $getClientId) {
            TextField("Client id", text: $tmpClientId)
            Button("OK") {
                clientId = tmpClientId

                launchAuthWebpage()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please input your Spotify developer app ID")
        }
    }

    private func launchAuthWebpage() {
        guard let authorizationURL = spotifyViewModel.authorizationURL, !clientId.isEmpty else {
            return
        }

        spotifyViewModel.updateClientId(newClientId: clientId)

        let openConfig = NSWorkspace.OpenConfiguration()
        openConfig.activates = true

        NSWorkspace.shared.open(authorizationURL, configuration: openConfig)
    }

}
