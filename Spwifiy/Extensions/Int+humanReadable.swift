//
//  Int+humanReadable.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import Foundation

struct HumanFormat {
    let seconds: Int
    let minutes: Int
    let hours: Int
    let days: Int

    var description: String {
        [days, hours, minutes, seconds]
            .map { String(format: "%02d", $0) }
            .joined()
            .replacingOccurrences(of: "^(00)+", with: "", options: .regularExpression)
            .separate(every: 2, with: ":")
            .replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }
}

extension Int {
    var humanReadable: HumanFormat {
        var time = self / 1000

        let seconds = time % 60
        time /= 60

        let minutes = time % 60
        time /= 60

        let hours = time % 24
        time /= 24

        let days = time

        return HumanFormat(seconds: seconds, minutes: minutes, hours: hours, days: days)
    }
}
