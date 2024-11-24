//
//  Color+toHSB.swift
//  Spwifiy
//
//  Created by RangerEmerald on 11/24/24.
//

import SwiftUI

extension Color {
    struct HSB {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
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
