//
//  String+matches.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
