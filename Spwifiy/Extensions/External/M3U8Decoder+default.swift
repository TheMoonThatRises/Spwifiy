//
//  M3U8Decoder+shared.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import M3U8Decoder

extension M3U8Decoder {

    public static var `default`: M3U8Decoder {
        let decoder = M3U8Decoder()

        decoder.keyDecodingStrategy = .camelCase

        return decoder
    }

}
