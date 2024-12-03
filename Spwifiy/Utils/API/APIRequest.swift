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

    init() {
        let config = URLSessionConfiguration.default

        config.httpAdditionalHeaders = [
            "User-Agent": APIRequest.userAgent
        ]

        self.session = URLSession(configuration: config)
        self.session.configuration.urlCache = .spwifiyCache
    }

    public func request(url: URL, success: @escaping (Data?) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { data, _, error in
            if error == nil, let data = data {
                success(data)
            } else {
                success(nil)
            }
        }
        .resume()
    }

    public func request(urlString: String, success: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            return success(nil)
        }

        request(url: url, success: success)
    }

    public func request(url: URL) async -> String? {
        await withCheckedContinuation { continuation in
            request(url: url) { result in
                guard let result = result else {
                    return continuation.resume(returning: nil)
                }

                continuation.resume(returning: String(data: result, encoding: .utf8))
            }
        }
    }

    public func request(urlString: String) async -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        return await request(url: url)
    }

}
