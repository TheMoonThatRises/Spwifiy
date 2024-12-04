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
    let avPlayerItem: AVPlayerItem
    let track: Track
    let expiration: Date
    let sponsorBlock: SponsorBlockResponse
}
