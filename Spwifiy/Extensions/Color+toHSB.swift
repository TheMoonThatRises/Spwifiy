//
//  Color+toHSB.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

extension Color {
    struct HSB {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat

        func toRGB() -> NSColor {
            return NSColor(hue: hue,
                           saturation: saturation,
                           brightness: brightness,
                           alpha: 1)
        }
    }

    func toHSB() -> HSB {
        let nsColor = NSColor(self)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0

        nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        return HSB(hue: hue, saturation: saturation, brightness: brightness)
    }
}
