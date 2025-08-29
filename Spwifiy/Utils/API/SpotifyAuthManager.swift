//
//  SpotifyAuthManager.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import SwiftUI
import WebKit
import KeychainAccess

class SpotifyAuthManager: NSObject, WKHTTPCookieStoreObserver {

    public enum AuthStatus: Int {
        case success, failed, inProcess, cookieSet
    }

    public static let spDcCookieKey = "sp_dc_cookie"
    public static let authAccessResponse = "auth_access_resp"

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
        if authStatus == .failed {
            return
        }

        cookieStore.getAllCookies { cookies in
            if let spDcCookie = cookies.filter({ $0.name == "sp_dc" }).first {
                let encoder = JSONEncoder()

                do {
                    self.keychain[
                        data: SpotifyAuthManager.spDcCookieKey
                    ] = try encoder.encode(SpotifyAuthCookie(cookie: spDcCookie))

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
