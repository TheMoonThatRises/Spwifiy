//
//  SponsorBlockResponse.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/3/24.
//

import Foundation

struct SponsorBlockItem: Decodable {
    let category: String
    let actionType: String
    let segment: [Double]
    let UUID: String
    let videoDuration: Double
    let locked: Int
    let votes: Int
    let description: String
}

struct SponsorBlockResponse {
    let items: [SponsorBlockItem]
    let response: String

    init(response: String) {
        let decoder = JSONDecoder()

        if let data = response.data(using: .utf8) {
            self.items = (try? decoder.decode([SponsorBlockItem].self, from: data)) ?? []
        } else {
            self.items = []
        }

        self.response = response
    }
}
