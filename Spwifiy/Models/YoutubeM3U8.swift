//
//  YoutubeM3U8.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import M3U8Decoder

struct EXTXMedia: Decodable {
    let uri: String
    let type: String
    let groupId: String
    let name: String
    let `default`: Bool
    let autoselect: Bool
}

// struct EXTXStreamInf: Decodable {
//     let bandwidth: Int
//     let codecs: String
//     let resolution: RESOLUTION
//     let frameRate: String
//     let videoRange: String
//     let audio: String
//     let closedCaptions: String
//     let video: String
// }

struct YoutubeM3U8: Decodable {
    let extm3u: Bool
    let extXIndependentSegments: Bool
    let extXMedia: [EXTXMedia]
//    let extXStreamInf: [EXTXStreamInf]
}
