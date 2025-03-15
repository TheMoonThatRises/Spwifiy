//
//  SpotifyOTP.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/14/25.
//

import Foundation

// adapted from https://github.com/KRTirtho/spotube/commit/59f298a935c87077a6abd50656f8a4ead44bd979
class SpotifyOTP {

    public static let shared = SpotifyOTP()

    private static let serverTimeUrl = "https://open.spotify.com/server-time"

    private let secret: String
    private let totp: TOTPGenerator?

    init() {
        self.secret = SpotifyOTP.generateSecret()

        if let totp = TOTPGenerator(secret: secret) {
            self.totp = totp
        } else {
            self.totp = nil
        }
    }

    private static func cleanBuffer(_ input: String) -> [UInt8] {
        let cleaned = input.replacingOccurrences(of: " ", with: "")

        var bytes = [UInt8]()
        var index = cleaned.startIndex

        while index < cleaned.endIndex {
            let nextIndex = cleaned.index(index, offsetBy: 2, limitedBy: cleaned.endIndex) ?? cleaned.endIndex
            let hexPair = cleaned[index..<nextIndex]

            if let byte = UInt8(hexPair, radix: 16) {
                bytes.append(byte)
            }

            index = nextIndex
        }

        return bytes
    }

    private static func base32FromBytes(_ data: [UInt8], _ secretSauce: String) -> String {
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

    private static func generateSecret() -> String {
        let secretSauce = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let secretCipherBytes: [Int] = [12, 56, 76, 33, 88, 44, 88, 33, 78, 78, 11, 66, 22, 22, 55, 69, 54]

        let processedBytes = secretCipherBytes.enumerated().map { (idx, elm) in
            elm ^ (idx % 33 + 9)
        }

        let joinedString = processedBytes.map { String($0) }.joined()
        let utf8Encoded = Array(joinedString.utf8)
        let hexString = utf8Encoded.map { String(format: "%02hhx", $0) }.joined()
        let secretBytes = cleanBuffer(hexString)
        let secret = base32FromBytes(secretBytes, secretSauce)

        return secret
    }

    private func generateOTP(serverTime: Int) -> String {
        return totp?.generateOTP(Double(serverTime)) ?? ""
    }

    public func generateOTP() async -> String {
        let decoder = JSONDecoder()

        guard let serverTimeResponse: Data = await APIRequest.shared.request(urlString: SpotifyOTP.serverTimeUrl),
              let serverTime = try? decoder.decode(SpotifyServerTime.self, from: serverTimeResponse) else {
            return ""
        }

        return generateOTP(serverTime: serverTime.serverTime)
    }

}
