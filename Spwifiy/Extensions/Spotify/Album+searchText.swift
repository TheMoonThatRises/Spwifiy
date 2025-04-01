//
//  Album+searchText.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/31/25.
//

import SpotifyWebAPI

extension Album {
    var searchText: String {
        (
            name +
            (label ?? "") +
            (artists?.description ?? "")
        ).lowercased()
    }
}
