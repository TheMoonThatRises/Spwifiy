//
//  ContextView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/18/25.
//

import SwiftUI
import SpotifyWebAPI

struct ContextView: View {

    let track: Track

    var body: some View {
        ContextButton(symbol: "spwifiy.download", text: "Download song") {

        }

        ContextButton(symbol: "spwifiy.timer", text: "Sleep timer") {

        }

        ContextButton(symbol: "spwifiy.hide", text: "Hide song") {

        }

        ContextButton(symbol: "spwifiy.share", text: "Share song") {

        }

        ContextButton(symbol: "spwifiy.add.library", text: "Add to library") {

        }

        ContextButton(symbol: "spwifiy.add.queue", text: "Add to Queue") {

        }

        ContextButton(symbol: "spwifiy.album", text: "View album") {

        }

        ContextButton(symbol: "spwifiy.artist", text: "View artist") {

        }
    }

}

struct ContextButton: View {

    let symbol: String
    let text: String

    let action: @MainActor () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(symbol)
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(text)
                    .font(.satoshi)
            }
            .foregroundStyle(.fgSecondary)
        }
        .buttonStyle(.plain)
        .cursorHover(.pointingHand)
    }

}
