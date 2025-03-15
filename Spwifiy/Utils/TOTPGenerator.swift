//
//  OTPGenerator.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/14/25.
//

import Foundation
import CryptoKit

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
}

class TOTPGenerator {
    public enum HMACAlgorithm {
        case sha1, sha256, sha512
    }

    private let secret: Data
    private let digits: Int
    private let period: TimeInterval
    private let algorithm: HMACAlgorithm

    init?(secret: String, digits: Int = 6, period: TimeInterval = 30, algorithm: HMACAlgorithm = .sha1) {
        guard let decodedSecret = Base32.decode(secret) else {
            return nil
        }

        self.secret = decodedSecret
        self.digits = digits
        self.period = period
        self.algorithm = algorithm
    }

    private func hmac(data: Data) -> Data? {
        switch algorithm {
        case .sha1: return Data(HMAC<Insecure.SHA1>.authenticationCode(for: data, using: SymmetricKey(data: secret)))
        case .sha256: return Data(HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: secret)))
        case .sha512: return Data(HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: secret)))
        }
    }

    private func extractOTP(from hash: Data) -> String {
        let offset = Int(hash.last! & 0x0F)
        let truncatedHash = hash.subdata(in: offset..<offset+4)
        let binaryCode = truncatedHash.withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian & 0x7FFFFFFF
        let otp = binaryCode % UInt32(pow(10, Float(digits)))

        return String(format: "%0\(digits)d", otp)
    }

    public func generateOTP(_ time: TimeInterval) -> String? {
        let counter = UInt64(time / period).bigEndian
        let counterData = withUnsafeBytes(of: counter) { Data($0) }

        guard let hash = hmac(data: counterData) else {
            return nil
        }

        return extractOTP(from: hash)
    }
}

