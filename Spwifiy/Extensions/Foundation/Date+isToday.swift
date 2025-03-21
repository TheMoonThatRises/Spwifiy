//
//  Date+isToday.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import Foundation

extension Date {
    func isToday() -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: Date())
    }
}
