//
//  VerifyClosedBeta.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/3/24.
//

import Foundation

class VerifyClosedBeta {

    public static let shared = VerifyClosedBeta()

    private var userListURL: URL {
        URL(string: "https://spwifiy.plduanm.com/closed_beta_list.txt")!
    }

    public func verifyUser(spotifyId: String, completion: @escaping (Bool) -> Void) {
        let spotifyIdHash = spotifyId.sha256

        APIRequest.shared.request(url: userListURL, noCache: true) { data in
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                completion(responseString.contains(spotifyIdHash))
            } else {
                completion(false)
            }
        }
    }

}
