//
//  View+cursorHover.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

enum Cursors {
    case pointingHand
    case resizeLeftRight
    case operationNotAllowed
}

extension View {
    func cursorHover(_ cursor: Cursors) -> some View {
        self.onHover { isHovered in
            if isHovered {
                switch cursor {
                case .pointingHand:
                    NSCursor.pointingHand.set()
                case .resizeLeftRight:
                    NSCursor.resizeLeftRight.set()
                case .operationNotAllowed:
                    NSCursor.operationNotAllowed.set()
                }
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}
