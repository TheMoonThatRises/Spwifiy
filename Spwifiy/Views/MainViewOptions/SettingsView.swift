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

    let extendedSpotifyAuth: () async -> Bool
    let extendedSpotifyLogout: () -> Void

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

                    Group {
                        HStack(spacing: 3) {
                            Text("Extended Login Token")
                                .font(.callout)
                                .foregroundStyle(.fgSecondary)

                            Spacer()

                            Button {
                                if settingsViewModel.extendedLogin == .failed {
                                    settingsViewModel.extendedLogin = .inProcess
                                } else {
                                    extendedSpotifyLogout()

                                    settingsViewModel.extendedLogin = .failed
                                }
                            } label: {
                                Group {
                                    if settingsViewModel.extendedLoginAnimation == .success {
                                        Text("Extended Spotify Logout")
                                    } else if settingsViewModel.extendedLoginAnimation == .failed {
                                        Text("Extended Spotify Login")
                                    } else if settingsViewModel.extendedLoginAnimation == .cookieSet {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .controlSize(.small)
                                            .task {
                                                settingsViewModel.extendedLogin = await extendedSpotifyAuth()
                                                    ? .success
                                                    : .failed
                                            }
                                    }
                                }
                                .font(.callout)
                                .foregroundStyle(.fgPrimary)
                                .padding(5)
                            }
                            .padding([.top, .bottom], 10)
                            .cursorHover(.pointingHand)
                            .disabled(![.success, .failed].contains(settingsViewModel.extendedLogin))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(50)
        .onAppear {
            if ![.success, .failed].contains(settingsViewModel.extendedLogin) {
                settingsViewModel.extendedLogin = .failed
            }
        }
        .onChange(of: settingsViewModel.displayDiscordRPC) { displayDiscordRPC in
            if displayDiscordRPC {
                avAudioPlayer.discordRPC.connect()
            } else {
                avAudioPlayer.discordRPC.disconnect()
            }
        }
    }

}
