//
//  SpotifyCustomLogin.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import SwiftUI
import WebKit
import KeychainAccess

class SpotifyAuthManager: NSObject, WKHTTPCookieStoreObserver {

    public enum AuthStatus {
        case success, failed, inProcess, cookieSet
    }

    public static let spDcCookieKey = "sp_dc_cookie"
    public static let spTCookieKey = "sp_t_cookie"

    @Binding var authStatus: AuthStatus

    let keychain: Keychain
    let webStore: WKWebsiteDataStore

    init(webStore: WKWebsiteDataStore, authStatus: Binding<AuthStatus>) {
        self._authStatus = authStatus
        self.keychain = Keychain(service: SpwifiyApp.service)
        self.webStore = webStore

        super.init()

        self.webStore.httpCookieStore.add(self)
    }

    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { cookies in
            if let spDcCookie = cookies.filter({ $0.name == "sp_dc" }).first,
               let spTCookie = cookies.filter({ $0.name == "sp_t" }).first {
                let encoder = JSONEncoder()

                do {
                    self.keychain[
                        data: SpotifyAuthManager.spDcCookieKey
                    ] = try encoder.encode(SpotifyAuthCookie(cookie: spDcCookie))

                    self.keychain[
                        data: SpotifyAuthManager.spTCookieKey
                    ] = try encoder.encode(SpotifyAuthCookie(cookie: spTCookie))

                    self.authStatus = .cookieSet
                } catch {
                    print("unable to store cookie data in keychain: \(error)")

                    self.authStatus = .failed
                }

                cookies.forEach {
                    self.webStore.httpCookieStore.delete($0)
                }

                self.webStore.httpCookieStore.remove(self)
            }
        }
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
