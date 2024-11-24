//
//  URLCache+imageCache.swift
//  Spwifiy
//
//  Created by RangerEmerald on 11/24/24.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 512_000_000)
}
