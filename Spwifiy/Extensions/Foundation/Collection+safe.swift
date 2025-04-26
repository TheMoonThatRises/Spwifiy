//
//  Collection+safe.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/26/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
