//
//  PlayingElementView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/24/24.
//

import SwiftUI

struct PlayingElementView: View {

    @State var progress: Double = 84/177

    var body: some View {
        HStack {
            Group {
                Button {

                } label: {
                    Image("spwifiy.pause.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.previous")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.next")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.shuffle")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.loop")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Text("1:24")

                ProgressView(value: progress)
                    .frame(minWidth: 100)

                Text("2:57")

                Button {

                } label: {
                    Image("spwifiy.volume")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }

            Group {
                Image("devasset_playingalbum")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                VStack(alignment: .leading) {
                    Text("TTYL (Feat. IV JAY)")
                        .foregroundStyle(.fgPrimary)

                    Button {

                    } label: {
                        Text("Trade L, IV Jay")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)

                    Button {

                    } label: {
                        Text("UNSTEADY")
                    }
                    .buttonStyle(.plain)
                    .cursorHover(.pointingHand)
                }
            }

            Spacer()

            Group {
                Button {

                } label: {
                    Image("spwifiy.like")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.add.playlist")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.lyrics")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)

                Button {

                } label: {
                    Image("spwifiy.queue")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .cursorHover(.pointingHand)
            }
        }
        .foregroundStyle(.fgSecondary)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 81)
        .background(.fgSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
