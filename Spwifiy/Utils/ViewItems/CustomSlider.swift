//
//  PlayerSlider.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/3/24.
//

import SwiftUI

struct CustomSlider<Content: View>: View {

    typealias SliderLabel = (Double) -> Content

    @Binding var value: Double
    @Binding var maxValue: Double
    @Binding var isInteracting: Bool

    @State var sliderDistance: Double = 0
    @State var isHovering: Bool = false

    @ViewBuilder let valueLabel: SliderLabel?
    @ViewBuilder let maxLabel: SliderLabel?

    var range: ClosedRange<Double> {
        0...max(maxValue, 0)
    }

    init(value: Binding<Double>,
         maxValue: Binding<Double>,
         isInteracting: Binding<Bool>,
         valueLabel: @escaping SliderLabel,
         maxLabel: @escaping SliderLabel) {
        self._value = value
        self._maxValue = maxValue
        self._isInteracting = isInteracting
        self.valueLabel = valueLabel
        self.maxLabel = maxLabel
    }

    init(value: Binding<Double>,
         maxValue: Binding<Double>,
         isInteracting: Binding<Bool>) {
        self._value = value
        self._maxValue = maxValue
        self._isInteracting = isInteracting
        self.valueLabel = nil
        self.maxLabel = nil
    }

    var body: some View {
        HStack {
            valueLabel?(value)

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
                        .contentShape(.rect)
                        .cursorHover(.pointingHand)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { gesture in
                                    isInteracting = true

                                    let newValue = gesture.location.x / geometry.size.width * range.upperBound

                                    value = min(max(0, newValue), range.upperBound)
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
                    setSliderDistance(geometry)
                }
                .onAppear {
                    setSliderDistance(geometry)
                }
            }
            .frame(height: 30)

            maxLabel?(maxValue)
        }
    }

    private func setSliderDistance(_ geometry: GeometryProxy) {
        sliderDistance = value / max(range.upperBound, 1) * geometry.size.width
    }
}
