//
//  Date+convertor.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import Foundation

extension Date {

    public static func convertor(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        return dateFormatter.date(from: dateString)
    }

}
