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
}

extension Int {
    var humanRedable: HumanFormat {
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
