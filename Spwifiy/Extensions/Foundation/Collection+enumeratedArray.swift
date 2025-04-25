//
//  Collection+enumeratedArray.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/24/25.
//

import Foundation

extension Collection {
    func enumeratedArray() -> [(offset: Int, element: Self.Element)] {
        Array(enumerated())
    }
}
