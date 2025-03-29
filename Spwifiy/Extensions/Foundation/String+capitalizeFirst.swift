//
//  String+capitalizeFirst.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/29/25.
//

extension String {
    func capitalizeFirst() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }
}
