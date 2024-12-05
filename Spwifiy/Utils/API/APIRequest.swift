//
//  APIRequest.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import Foundation

class APIRequest {

    private static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                                   "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15"

    public static let shared = APIRequest()

    private let session: URLSession
    private let noCacheSession: URLSession

    init() {
        let config = URLSessionConfiguration.default

        config.httpAdditionalHeaders = [
            "User-Agent": APIRequest.userAgent
        ]

        self.session = URLSession(configuration: config)
        self.noCacheSession = URLSession(configuration: config)

        self.session.configuration.urlCache = .spwifiyCache
        self.noCacheSession.configuration.urlCache = nil
    }

    public func setCookie(cookie: HTTPCookie, noCache: Bool = false) {
        (noCache ? noCacheSession : session).configuration.httpCookieStorage?.setCookie(cookie)
    }

    public func removeCookie(cookie: HTTPCookie, noCache: Bool = false) {
        (noCache ? noCacheSession : session).configuration.httpCookieStorage?.deleteCookie(cookie)
    }

    public func request(request: URLRequest, noCache: Bool = false, success: @escaping (Data?) -> Void) {
        (noCache ? noCacheSession : session).dataTask(with: request) { data, _, error in
            if error == nil, let data = data {
                success(data)
            } else {
                success(nil)
            }
        }
        .resume()
    }

    public func request(url: URL, noCache: Bool = false, success: @escaping (Data?) -> Void) {
        request(request: URLRequest(url: url), noCache: noCache, success: success)
    }

    public func request(urlString: String, noCache: Bool = false, success: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            return success(nil)
        }

        request(url: url, noCache: noCache, success: success)
    }

    public func request(url: URL, noCache: Bool = false) async -> String? {
        await withCheckedContinuation { continuation in
            request(url: url, noCache: noCache) { result in
                guard let result = result else {
                    return continuation.resume(returning: nil)
                }

                continuation.resume(returning: String(data: result, encoding: .utf8))
            }
        }
    }

    public func request(urlString: String, noCache: Bool = false) async -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        return await request(url: url, noCache: noCache)
    }

}
