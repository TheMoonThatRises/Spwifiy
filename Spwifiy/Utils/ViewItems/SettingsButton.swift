//
//  SettingsButton.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 8/29/25.
//

import SwiftUI

struct SettingsButton<Content: View>: View {

    let text: String
    let action: () -> Void
    @ViewBuilder let buttonLabel: Content

    var body: some View {
        HStack(spacing: 3) {
            Text(text)
                .font(.callout)
                .foregroundStyle(.fgSecondary)

            Spacer()

            Button {
                action()
            } label: {
                buttonLabel
                    .font(.callout)
                    .foregroundStyle(.fgPrimary)
                    .padding(5)
            }
            .padding([.top, .bottom], 10)
            .cursorHover(.pointingHand)
        }
    }

}
