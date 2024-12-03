//
//  String+unescapeUnicodeCharacters.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import Foundation

// https://stackoverflow.com/a/54192888/28538953
extension String {
    var unescapingUnicodeCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, "Any-Hex/Java" as NSString, true)

        return mutableString as String
    }
}
