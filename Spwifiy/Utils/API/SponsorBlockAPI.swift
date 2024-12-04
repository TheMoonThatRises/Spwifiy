//
//  SponsorBlockAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import Foundation

class SponsorBlockAPI {

    public static let shared = SponsorBlockAPI()

    private var sponsorBlockCache: [String: SponsorBlockResponse] = [:]

    private let requestParams: [URLQueryItem] = [
        .init(name: "category[]", value: "sponsor"),
        .init(name: "category[]", value: "selfpromo"),
        .init(name: "category[]", value: "interaction"),
        .init(name: "category[]", value: "intro"),
        .init(name: "category[]", value: "outro"),
        .init(name: "category[]", value: "music_offtopic"),
        .init(name: "actionType", value: "skip")
    ]

    private var requestURL: (String) -> URL {
        { videoId in
            var allParams: [URLQueryItem] = [.init(name: "videoID", value: videoId)]

            allParams.append(contentsOf: self.requestParams)

            var requestUrl = URLComponents(string: "https://sponsor.ajay.app/api/skipSegments")!
            requestUrl.queryItems = allParams

            return requestUrl.url!
        }
    }

    public func getSkipSegments(videoId: String) async -> SponsorBlockResponse {
        if let cacheResponse = sponsorBlockCache[videoId] {
            return cacheResponse
        }

        let response = await APIRequest.shared.request(url: requestURL(videoId))

        return SponsorBlockResponse(response: response ?? "No response")
    }

}
