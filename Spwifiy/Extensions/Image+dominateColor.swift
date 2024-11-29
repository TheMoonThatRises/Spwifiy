//
//  Image+dominateColor.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI
import CryptoKit

extension Image {
    private static var cache: [String: Color] = [:]

    @MainActor
    func calculateDominantColor(id: String) -> Color? {
        guard let cgImage = ImageRenderer(content: self).cgImage else { return nil }

        if let color = Image.cache[id] {
            return color
        }

        let totalPixels = cgImage.width * cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * cgImage.width
        let bitsPerComponent = 8
        var pixelData = [UInt8](repeating: 0, count: totalPixels * bytesPerPixel)

        guard let context = CGContext(data: &pixelData,
                                      width: cgImage.width,
                                      height: cgImage.height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        var colorScores: [UInt32: Double] = [:]

        var idx = 0

        while idx < totalPixels {
            let index = idx * bytesPerPixel
            let red = CGFloat(pixelData[index]) / 255.0
            let green = CGFloat(pixelData[index + 1]) / 255.0
            let blue = CGFloat(pixelData[index + 2]) / 255.0
            let alpha = CGFloat(pixelData[index + 3]) / 255.0

            if alpha > 0 { // Ignore transparent pixels
                           // Convert to HSB for vibrancy calculation
                let color = Color(red: red, green: green, blue: blue, opacity: alpha)
                var hsb = color.toHSB()

                if hsb.brightness < 0.7 {
                    hsb = Color.HSB(hue: hsb.hue,
                                    saturation: hsb.saturation,
                                    brightness: 0.7)
                }

                let vibrancy = hsb.saturation * hsb.brightness

                let reColor = Color.hsbToRGB(hsb: hsb)

                // Create a color key for exact RGB matches
                let colorKey = UInt32(reColor.redComponent * 255) << 16
                            | UInt32(reColor.greenComponent * 255) << 8
                            | UInt32(reColor.blueComponent * 255)

                // Increment the score by vibrancy for this color
                colorScores[colorKey, default: 0] += vibrancy
            }

            idx += 1000
        }

        // Find the color with the highest score
        guard let mostVibrantKey = colorScores.max(by: { $0.value < $1.value })?.key else { return nil }

        let color = Color(red: CGFloat((mostVibrantKey >> 16) & 0xFF) / 255.0,
                          green: CGFloat((mostVibrantKey >> 8) & 0xFF) / 255.0,
                          blue: CGFloat(mostVibrantKey & 0xFF) / 255.0)

        Image.cache[id] = color

        return color
    }
}
