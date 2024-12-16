//
//  Font+Custom.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI

extension Font {
    public static var satoshiCustom: (String?, CGFloat) -> Font {
        { type, size in
            var fontBase = "Satoshi"

            if let type = type {
                fontBase += "-\(type)"
            }

            return .custom(fontBase, fixedSize: size)
        }
    }

    public static let satoshi: Font = .satoshiCustom(nil, 12)

    public static var satoshiLight: (CGFloat) -> Font {
        { size in
            .satoshiCustom("Light", size)
        }
    }

    public static var satoshiBlack: (CGFloat) -> Font {
        { size in
            .satoshiCustom("Black", size)
        }
    }
}
