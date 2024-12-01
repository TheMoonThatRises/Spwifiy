//
//  DotButton.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import SwiftUI

struct DotButton: View {

    @Binding var toggle: Bool

    var image: Image

    var body: some View {
        ZStack(alignment: .center) {
            Button {
                toggle.toggle()
            } label: {
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(toggle ? .sPrimary : .fgSecondary)
            }
            .buttonStyle(.plain)
            .cursorHover(.pointingHand)

            if toggle {
                Circle()
                    .frame(width: 3, height: 3)
                    .foregroundStyle(.sPrimary)
                    .offset(y: 17)
            }
        }
    }

}
