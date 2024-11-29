//
//  NavButton.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

public struct NavButton<Label>: View where Label: View {

    @Binding var currentView: MainViewOptions

    let currentButton: MainViewOptions
    let isSelected: Bool

    let action: @MainActor () -> Void
    let label: Label

    init(currentButton: MainViewOptions,
         currentView: Binding<MainViewOptions>,
         action: @escaping @MainActor () -> Void,
         @ViewBuilder label: () -> Label) {
        self._currentView = currentView

        self.currentButton = currentButton
        self.isSelected = currentButton == currentView.wrappedValue

        self.action = action
        self.label = label()
    }

    @MainActor public var body: some View {
        label
            .foregroundStyle(isSelected ? .fgPrimary : .fgSecondary)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.fgPrimary.opacity(0.1))
                        .allowsHitTesting(false)
                }
            }
    }

    func toButton() -> some View {
        Button {
            action()

            withAnimation(.defaultAnimation) {
                self.currentView = self.currentButton
            }
        } label: {
            body
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .cursorHover(.pointingHand)
    }
}
