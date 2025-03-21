//
//  Album+combId.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import SpotifyWebAPI

extension Album {

    var combId: String {
        (artists?.description ?? "") +
        (label ?? "") +
        (id ?? "") +
        (uri ?? "") +
        name
    }

}
