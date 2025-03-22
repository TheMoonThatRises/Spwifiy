//
//  Date+hasExpired.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import Foundation

extension Date {
    public func hasExpired(buffer: TimeInterval = 0.0) -> Bool {
        return timeIntervalSinceNow <= buffer
    }
}
