//
//  Base32.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 8/29/25.
//

import Foundation

class Base32 {
    private static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

    public static func decode(_ base32: String) -> Data? {
        var bits = ""

        for char in base32.uppercased() {
            guard let index = alphabet.firstIndex(of: char) else {
                continue
            }

            let binary = String(alphabet.distance(from: alphabet.startIndex, to: index), radix: 2)

            bits += String(repeating: "0", count: 5 - binary.count) + binary
        }

        var bytes = [UInt8]()

        while bits.count >= 8 {
            let byteString = bits.prefix(8)

            bits = String(bits.dropFirst(8))

            if let byte = UInt8(byteString, radix: 2) {
                bytes.append(byte)
            }
        }

        return Data(bytes)
    }

    public static func fromBytes(_ data: [UInt8], _ secretSauce: String) -> String {
        var bitsAvailable = 0
        var buffer: UInt64 = 0
        var result = ""
        let sauceArray = Array(secretSauce)

        for byte in data {
            buffer = (buffer << 8) | UInt64(byte)
            bitsAvailable += 8

            while bitsAvailable >= 5 {
                let shift = bitsAvailable - 5
                let index = Int((buffer >> shift) & 0x1F)

                result.append(sauceArray[index])

                bitsAvailable -= 5

                buffer &= (1 << UInt64(bitsAvailable)) - 1
            }
        }

        if bitsAvailable > 0 {
            let shift = 5 - bitsAvailable
            let index = Int((buffer << shift) & 0x1F)

            result.append(sauceArray[index])
        }

        return result
    }
}
