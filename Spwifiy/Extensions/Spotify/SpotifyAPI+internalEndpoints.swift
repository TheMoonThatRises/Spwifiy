//
//  SpotifyAPI+internalEndpoints.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/14/24.
//

import Foundation
import Combine
import SpotifyWebAPI

extension SpotifyAPI {

    private static var baseURL: String {
        "https://api.spotify.com/v1"
    }

    enum ViewTypes: String {
        case album = "album"
        case playlist = "playlist"
        case artist = "artist"
        case show = "show"
        case station = "station"
        case episode = "episode"
        case merch = "merch"
        case artistConcerts = "artist_concerts"
        case uriLink = "uri_link"
    }

    enum ViewEndpoints: String {
        case newReleasePage = "new-release-page"
        case madeForXHub = "made-for-x-hub"
        case myMixGenres = "my-mix-genres"
        case artistSeedMixes = "artist-seed-mixes"
        case myMixDecades = "my-mix-decades"
        case myMixMoods = "my-mix-moods"
        case podcastsAndMore = "podcasts-and-more"
        case uniquelyYoursInHub = "uniquely-yours-in-hub"
        case madeForXDailymix = "made-for-x-dailymix"
        case madeForXDiscovery = "made-for-x-discovery"
    }

    func getView(view: ViewEndpoints,
                 limit: Int = 20,
                 contentLimit: Int = 10,
                 types: [ViewTypes],
                 imageStyle: String = "gradient_overlay",
                 includeExternal: String = "audio",
                 locale: String? = nil,
                 market: String? = nil,
                 country: String? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        guard let accessToken = self.authorizationManager.accessToken else {
            return SpotifyGeneralError.unauthorized(
                "unauthorized: no access token"
            )
            .anyFailingPublisher()
        }

        var queryParams: [String: String] = [
            "limit": String(limit),
            "content_limit": String(contentLimit),
            "types": types.map { $0.rawValue }.joined(separator: ","),
            "image_style": imageStyle,
            "include_external": includeExternal,
            "timestamp": Date().ISO8601Format()
        ]

        if let locale = locale {
            queryParams["locale"] = locale
        }

        if let market = market {
            queryParams["market"] = market
        }

        if let country = country {
            queryParams["country"] = country
        }

        let queryParamString = queryParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        guard let url = URL(string: "\(SpotifyAPI.baseURL)/views/\(view.rawValue)?\(queryParamString)") else {
            return SpotifyGeneralError.other(
                "internal view: url is nil"
            )
            .anyFailingPublisher()
        }

        print(url)

        var headers = Headers.bearerAuthorization(accessToken)

        headers["content-type"] = "application/json"
        headers["accept"] = "application/json"

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers
//        urlRequest.httpBody = bodyData

        return self.networkAdaptor(urlRequest)
            .eraseToAnyPublisher()
    }

    public func getMadeForXDailyHub(sink: ((Subscribers.Completion<any Error>) -> Void)? = nil,
                                    receiveValue: ((MadeForDailyXHub) -> Void)? = nil) {
        CombineHandler.handler(result: getView(view: .madeForXHub, types: [.playlist]),
                               sink: sink) { data, response in
            print(response.statusCode)

//            let madeMix = MadeForDailyXHub(data)

//            receiveValue?(madeMix)
        }
    }
}
