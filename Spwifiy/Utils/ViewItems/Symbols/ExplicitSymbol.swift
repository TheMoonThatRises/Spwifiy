//
//  ExplicitSymbol.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/18/25.
//

import SwiftUI

struct ExplicitSymbol: View {

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .foregroundStyle(.fgSecondary)
            .frame(width: 13, height: 13)
            .overlay {
                Text("E")
                    .foregroundStyle(.fgTertiary)
                    .font(.satoshiBlack(8))
            }
    }

}
