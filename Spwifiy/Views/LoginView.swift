//
//  LoginView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import SwiftUI

struct LoginView: View {

    @Binding var authStatus: SpotifyAuthManager.AuthStatus

    @State var isLoggingIn: Bool = false

    var body: some View {
        VStack {
            if isLoggingIn {
                SpotifyWebView(authStatus: $authStatus)
            } else {
                Button {
                    isLoggingIn.toggle()
                } label: {
                    Text("Login with Spotify")
                        .font(.satoshiBlack(24))
                        .padding()
                }
                .cursorHover(.pointingHand)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}
