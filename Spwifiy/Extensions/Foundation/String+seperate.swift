//
//  String+seperate.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import Foundation

// https://stackoverflow.com/a/47906901/28538953
extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}
