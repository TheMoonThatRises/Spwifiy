//
//  QueuePlayerItem.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import Foundation
import AVFoundation
import SpotifyWebAPI

struct QueuePlayerItem {
    let m3u8: URL
    let track: Track
    let expiration: Date
    let sponsorBlockSegments: [(Double, Double)]
}
