//
//  ExpandSearch.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI

struct ExpandSearch: View {

    @State var didSelectSearch: Bool = false

    @Binding var searchText: String

    var body: some View {
        Group {
            HStack {
                Button {
                    withAnimation {
                        didSelectSearch.toggle()
                    }
                } label: {
                    Image("spwifiy.search")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                if didSelectSearch {
                    TextField(text: $searchText) {
                        Text("Search")
                            .font(.title3)
                    }
                    .padding(.trailing, 10)
                }
            }
        }
        .foregroundStyle(didSelectSearch ? .fgPrimary : .fgSecondary)
        .frame(minWidth: 40, maxWidth: 300)
        .overlay {
            if didSelectSearch {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.fgPrimary.opacity(0.1))
                    .allowsHitTesting(false)
            }
        }
    }

}
