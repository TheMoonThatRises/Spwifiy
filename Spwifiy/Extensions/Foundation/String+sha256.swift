//
//  String+sha256.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/3/24.
//

import Foundation
import CryptoKit

extension String {
    var sha256: String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)

        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
