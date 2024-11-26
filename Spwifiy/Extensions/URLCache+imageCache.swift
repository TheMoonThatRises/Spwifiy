//
//  URLCache+imageCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 50_000_000)
}
