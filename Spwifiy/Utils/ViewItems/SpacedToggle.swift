//
//  SpacedToggle.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/18/25.
//

import SwiftUI

struct SpacedToggle<Label: View>: View {

    @Binding var isOn: Bool

    @ViewBuilder let label: Label

    var body: some View {
        HStack {
            label

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(.sPrimary)
        }
    }

}
