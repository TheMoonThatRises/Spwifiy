//
//  Image+dominateColor.swift
//  Spwifiy
//
//  Created by RangerEmerald on 11/24/24.
//

import SwiftUI
import CryptoKit

extension Image {
    private static var cache: [String: Color] = [:]

    @MainActor
    func calculateDominantColor(id: String) -> Color? {
        guard let cgImage = ImageRenderer(content: self).cgImage else {
            return nil
        }

        if let color = Image.cache[id] {
            return color
        }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var colorScores: [UInt32: Double] = [:]

        var idx = 0
        let totalPixels = width * height

        while idx < totalPixels {
            let index = idx * bytesPerPixel
            let red = CGFloat(pixelData[index]) / 255.0
            let green = CGFloat(pixelData[index + 1]) / 255.0
            let blue = CGFloat(pixelData[index + 2]) / 255.0
            let alpha = CGFloat(pixelData[index + 3]) / 255.0

            if alpha > 0 { // Ignore transparent pixels
                // Convert to HSB for vibrancy calculation
                let color = Color(red: red, green: green, blue: blue, opacity: alpha)
                let hsb = color.toHSB()
                let vibrancy = hsb.saturation * hsb.brightness

                // Create a color key for exact RGB matches
                let colorKey = UInt32(red * 255) << 16 | UInt32(green * 255) << 8 | UInt32(blue * 255)

                // Increment the score by vibrancy for this color
                colorScores[colorKey, default: 0] += vibrancy
            }

            idx += 1000
        }

        // Find the color with the highest score
        guard let mostVibrantKey = colorScores.max(by: { $0.value < $1.value })?.key else {
            return nil
        }

        let red = CGFloat((mostVibrantKey >> 16) & 0xFF) / 255.0
        let green = CGFloat((mostVibrantKey >> 8) & 0xFF) / 255.0
        let blue = CGFloat(mostVibrantKey & 0xFF) / 255.0

        let color = Color(red: red, green: green, blue: blue)

        Image.cache[id] = color

        return color
    }
}
