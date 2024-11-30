//
//  WrapHStack.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/28/24.
//

import SwiftUI

// Adapted from https://stackoverflow.com/a/62103264/28538953
struct WrapHStack<Content: View>: View {
    var items: [String]
    var itemToView: (String) -> Content

    @State private var totalHeight = CGFloat.infinity

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
       .frame(maxHeight: totalHeight)
    }

    private func generateContent(in geom: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.self) { item in
                self.itemToView(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { dim in
                        if abs(width - dim.width) > geom.size.width {
                            width = 0
                            height -= dim.height
                        }

                        let result = width

                        if item == self.items.last! {
                            width = 0
                        } else {
                            width -= dim.width
                        }

                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height

                        if item == self.items.last! {
                            height = 0
                        }

                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)

            Task { @MainActor in
                binding.wrappedValue = rect.size.height
            }

            return .clear
        }
    }
}
