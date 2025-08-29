//
//  SpotifyAuthCookie.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import Foundation

struct SpotifyAuthCookie: Codable {
    let name: String
    let value: String
    let expiresDate: Date
    let domain: String

    var httpCookie: HTTPCookie? {
        let properties: [HTTPCookiePropertyKey: Any] = [
            .domain: domain,
            .path: "/",
            .name: name,
            .value: value,
            .secure: true,
            .expires: expiresDate
        ]

        return HTTPCookie(properties: properties)
    }

    init(cookie: HTTPCookie) {
        self.name = cookie.name
        self.value = cookie.value
        self.expiresDate = cookie.expiresDate ?? Date.now
        self.domain = cookie.domain
    }
}
