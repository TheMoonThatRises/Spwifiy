//
//  Font+Custom.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI

extension Font {
    public static var sotashiCustom: (String?, CGFloat) -> Font {
        { type, size in
            var fontBase = "Satoshi"

            if let type = type {
                fontBase += "-\(type)"
            }

            return .custom(fontBase, fixedSize: size)
        }
    }

    public static let satoshi: Font = .sotashiCustom(nil, 12)

    public static var satoshiLight: (CGFloat) -> Font {
        { size in
            .sotashiCustom("Light", size)
        }
    }

    public static var satoshiBlack: (CGFloat) -> Font {
        { size in
            .sotashiCustom("Black", size)
        }
    }
}
