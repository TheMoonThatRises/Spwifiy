//
//  Array+artistJoin.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import Foundation
import SpotifyWebAPI

extension Array<Artist> {

    var description: String {
        map { $0.name }.joined(separator: ", ")
    }

}
