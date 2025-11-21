//
//  SpotifyOTP.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/14/25.
//

import Foundation
import SwiftyJSON

// adapted from https://github.com/KRTirtho/spotube/commit/59f298a935c87077a6abd50656f8a4ead44bd979
class SpotifyOTP {
    private static let serverTimeUrl = "https://open.spotify.com/api/server-time"
    private static var secretsUrl: String {
        "https://github.com/xyloflake/spot-secrets-go/blob/main/secrets/secretDict.json?raw=true"
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

    private static func fetchSecretCipher() async throws -> ([Int], String) {
        try await withCheckedThrowingContinuation { continuation in
            APIRequest.shared.request(urlString: secretsUrl, noCache: true) { data in
                guard let data = data,
                      let json = try? JSON(data: data),
                      let vers = json.dictionary else {
                    continuation.resume(throwing: SpwifiyErrors.failedSecretsRetrievel)

                    return
                }

                let sortedVers = vers.keys.map { Int($0) ?? 0 }.sorted { $0 > $1 }
                let latestVer = String(sortedVers[0])

                guard let cipher = vers[latestVer]?.array else {
                    continuation.resume(throwing: SpwifiyErrors.failedSecretsRetrievel)

                    return
                }

                continuation.resume(returning: (cipher.map { $0.int ?? 0 }, latestVer))
            }
        }
    }

    public static func generateSecret() async throws -> (String, String) {
        let secretSauce = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let (secretCipherBytes, totpVer) = try await fetchSecretCipher()

        let processedBytes = secretCipherBytes.enumerated().map { (idx, elm) in
            elm ^ (idx % 33 + 9)
        }

        let joinedString = processedBytes.map { String($0) }.joined()
        let utf8Encoded = Array(joinedString.utf8)
        let hexString = utf8Encoded.map { String(format: "%02hhx", $0) }.joined()
        let secretBytes = cleanBuffer(hexString)
        let secret = Base32.fromBytes(secretBytes, secretSauce)

        return (secret, totpVer)
    }

    public static func retrieveServerTime() async -> Int? {
        let decoder = JSONDecoder()

        guard let url = URL(string: SpotifyOTP.serverTimeUrl) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(RandomUserAgent.generate(), forHTTPHeaderField: "User-Agent")
        request.setValue("open.spotify.com", forHTTPHeaderField: "Host")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        return await withCheckedContinuation { continuation in
            APIRequest.shared.request(request: request, noCache: true) { data in
                guard let serverTimeResponse = data,
                      let serverTime = try? decoder.decode(SpotifyServerTime.self, from: serverTimeResponse) else {
                    continuation.resume(returning: nil)

                    return
                }

                continuation.resume(returning: serverTime.serverTime)
            }
        }
    }

}
