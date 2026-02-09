//
//  SpotifyCustomLoginView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 8/29/25.
//

import SwiftUI
import WebKit

struct SpotifyCustomLoginView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var extendedLogin: SpotifyAuthManager.AuthStatus

    var body: some View {
        SpotifyWebView(authStatus: $extendedLogin)
    }

}

struct SpotifyWebView: NSViewRepresentable {

    let webStore: WKWebsiteDataStore

    let spotifyAuthManager: SpotifyAuthManager
    var webView: WKWebView

    init(authStatus: Binding<SpotifyAuthManager.AuthStatus>) {
        self.webStore = .default()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = webStore
        config.limitsNavigationsToAppBoundDomains = false

        self.webView = WKWebView(frame: .zero, configuration: config)

        self.spotifyAuthManager = SpotifyAuthManager(
            webStore: self.webStore,
            authStatus: authStatus
        )

        self.webView.load(URLRequest(url: URL(string: "https://accounts.spotify.com/login")!))
    }

    func makeNSView(context: Context) -> some NSView {
        return webView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {

    }

}
