//
//  View+cursorHover.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

enum Cursors {
    case pointingHand
}

extension View {
    func cursorHover(_ cursor: Cursors) -> some View {
        self.onHover { isHovered in
            if isHovered {
                switch cursor {
                default:
                    NSCursor.pointingHand.push()
                }
            } else {
                NSCursor.pop()
            }
        }
    }
}
