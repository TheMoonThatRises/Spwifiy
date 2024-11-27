//
//  Array+splitInSubArrays.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/26/24.
//

import Foundation

extension Array {
    func splitInSubArrays(into size: Int) -> [[Element]] {
        return (0..<size).map {
            stride(from: $0, to: count, by: size).map { self[$0] }
        }
    }
}
