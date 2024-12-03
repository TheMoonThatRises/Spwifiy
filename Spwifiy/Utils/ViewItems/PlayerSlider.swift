//
//  PlayerSlider.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/3/24.
//

import SwiftUI

struct PlayerSlider: View {
    @Binding var value: Double
    @Binding var maxValue: Double
    @Binding var isInteracting: Bool

    @State var sliderDistance: Double = 0
    @State var isHovering: Bool = false

    var range: ClosedRange<Double> {
        0...maxValue
    }

    init(value: Binding<Double>, maxValue: Binding<Double>, isInteracting: Binding<Bool>) {
        self._value = value
        self._maxValue = maxValue
        self._isInteracting = isInteracting
    }

    var body: some View {
        HStack {
            Text(Int(value * 1000).humanReadable.description)
                .frame(width: 50)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)

                    Capsule()
                        .fill(isHovering ? .sPrimary : .fgPrimary)
                        .frame(width: sliderDistance, height: 6)

                    if isHovering || isInteracting {
                        Circle()
                            .fill(.primary)
                            .frame(width: 16, height: 16)
                            .offset(x: sliderDistance - 4)
                    }

                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .cursorHover(.pointingHand)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isInteracting = true

                                    let newValue = gesture.location.x / geometry.size.width

                                    value = min(
                                        max(
                                            range.lowerBound,
                                            Double(newValue) * (range.upperBound - range.lowerBound) + range.lowerBound
                                        ),
                                        range.upperBound
                                    )
                                }
                                .onEnded { _ in
                                    isInteracting = false
                                }
                        )
                        .onHover { value in
                            isHovering = value
                        }
                }
                .onChange(of: value) { _ in
                    sliderDistance = value / max(range.upperBound, 1) * geometry.size.width
                }
            }
            .frame(height: 30)

            Text(Int(maxValue * 1000).humanReadable.description)
                .frame(width: 50)
        }
    }
}
