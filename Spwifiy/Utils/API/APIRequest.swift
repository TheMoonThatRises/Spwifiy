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
    }

    public func request(url: URL) async -> String? {
        await withCheckedContinuation { continuation in
            session.dataTask(with: URLRequest(url: url)) { data, _, error in
                if error == nil, let data = data {
                    continuation.resume(returning: String(data: data, encoding: .utf8))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            .resume()
        }
    }

    public func request(urlString: String) async -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        return await request(url: url)
    }

}
