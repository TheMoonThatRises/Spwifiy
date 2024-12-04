//
//  String+shorthandNumber.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import Foundation

extension String {
    var shorthandConvert: Int {
        var string = self
        var multiplier = 1

        let lastLetter = String(string.last ?? "0").lowercased()
        if lastLetter.matches("[kmb]") {
            string = String(string.dropLast())

            switch lastLetter {
            case "k":
                multiplier = 1_000
            case "m":
                multiplier = 1_000_000
            case "b":
                multiplier = 1_000_000_000
            default:
                fatalError("Got unexpected last letter: \(lastLetter)")
            }
        }

        return (Int(string) ?? 0) * multiplier
    }
}
