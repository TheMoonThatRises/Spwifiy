//
//  Color+Custom.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/23/24.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension ShapeStyle where Self == Color {
    static var sPrimary: Color {
        Color(hex: 0x1ED760)
    }

    static var lightPrimary: Color {
        Color(hex: 0x13BF51)
    }

    static var fgPrimary: Color {
        Color(hex: 0xE0E0E0)
    }

    static var fgSecondary: Color {
        Color(hex: 0x898989)
    }

    static var fgTertiary: Color {
        Color(hex: 0x323232)
    }

    static var fgLightPrimary: Color {
        Color(hex: 0x1A1A1A)
    }

    static var fgLightSecondary: Color {
        Color(hex: 0x6E6E6E)
    }

    static var bgMain: Color {
        Color(hex: 0x060606)
    }

    static var bgPrimary: Color {
        Color(hex: 0x111111)
    }

    static var bgSecondary: Color {
        Color(hex: 0x202020)
    }

    static var bgLightMain: Color {
        Color(hex: 0xF0F0F0)
    }
}
