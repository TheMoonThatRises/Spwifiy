//
//  SettingsView.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/18/25.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var avAudioPlayer: AVAudioPlayer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Settings")
                    .foregroundStyle(.fgPrimary)
                    .font(.title)
                    .bold()

                Spacer()
                    .frame(height: 40)

                Group {
                    Text("Explicit Content")
                        .foregroundStyle(.fgPrimary)
                        .font(.title2)
                        .bold()

                    SpacedToggle(isOn: $settingsViewModel.playExplicit) {
                        HStack(spacing: 3) {
                            Text("Allow explicit (")
                                .font(.callout)
                                .foregroundStyle(.fgSecondary)

                            ExplicitSymbol()

                            Text(") content")
                                .font(.callout)
                                .foregroundStyle(.fgSecondary)
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)

                Group {
                    Text("Miscellaneous")
                        .foregroundStyle(.fgPrimary)
                        .font(.title2)
                        .bold()

                    SpacedToggle(isOn: $settingsViewModel.displayDiscordRPC) {
                        HStack(spacing: 3) {
                            Text("Allow Discord Activity Presence")
                                .font(.callout)
                                .foregroundStyle(.fgSecondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(50)
        .onChange(of: settingsViewModel.displayDiscordRPC) { displayDiscordRPC in
            if displayDiscordRPC {
                avAudioPlayer.discordRPC.connect()
            } else {
                avAudioPlayer.discordRPC.disconnect()
            }
        }
    }

}
