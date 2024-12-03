//
//  URLCache+imageCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import Foundation

extension URLCache {
    static let spwifiyCache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 512_000_000)
}
