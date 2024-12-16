//
//  UnderlinedViewMenu.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/13/24.
//

import SwiftUI

struct UnderlinedViewMenu<Option: Equatable & RawRepresentable>: View where Option.RawValue: StringProtocol {

    let types: [Option]

    @Binding var currentOption: Option

    var body: some View {
        HStack {
            ForEach(types, id: \.rawValue) { type in
                VStack {
                    Button {
                        withAnimation(.defaultAnimation) {
                            currentOption = type
                        }
                    } label: {
                        Text(type.rawValue)
                            .foregroundStyle(.fgSecondary)
                            .padding(7)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    if currentOption == type {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.sPrimary)
                            .frame(height: 3)
                    }

                    Spacer()
                }
                .fixedSize(horizontal: true, vertical: false)

                if type != types.last {
                    Spacer()
                        .frame(width: 25)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding()
        .font(.satoshiBlack(12))
    }

}
