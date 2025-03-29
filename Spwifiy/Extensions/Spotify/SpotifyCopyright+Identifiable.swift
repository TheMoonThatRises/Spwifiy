//
//  SpotifyCopyright+Identifiable.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/29/25.
//

import Foundation
import SpotifyWebAPI

extension SpotifyCopyright: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }
}
