//
//  String+unescapeHex.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation

extension String {

    func unescapeHexEscapedString() -> String {
        var result = ""
        var idx = startIndex

        while idx < endIndex {
            if self[idx] == "\\" && index(after: idx) < endIndex && self[index(after: idx)] == "x" {
                let hexStart = index(idx, offsetBy: 2)
                let hexEnd = index(hexStart, offsetBy: 2, limitedBy: endIndex) ?? endIndex
                let hexSubstring = self[hexStart..<hexEnd]

                if let scalar = UInt32(hexSubstring, radix: 16), let unicodeScalar = UnicodeScalar(scalar) {
                    result.append(String(unicodeScalar))
                    idx = hexEnd
                    continue
                }
            }
            result.append(self[idx])
            idx = index(after: idx)
        }

        return result
    }

}
