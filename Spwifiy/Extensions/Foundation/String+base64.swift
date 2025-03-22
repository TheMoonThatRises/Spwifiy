//
//  String+base64.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/21/25.
//

import Foundation

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
