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

    let clearSpotifyCache: () -> Void

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
                            Text("Allow Discord activity presence")
                                .font(.callout)
                                .foregroundStyle(.fgSecondary)
                        }
                    }

                    SettingsButton(text: "Extended login token") {
                        if settingsViewModel.extendedLogin == .failed {
                            settingsViewModel.extendedLogin = .inProcess
                        } else {
                            extendedSpotifyLogout()

                            settingsViewModel.extendedLogin = .failed
                        }
                    } buttonLabel: {
                        Group {
                            if settingsViewModel.extendedLoginAnimation == .success {
                                Text("Extended Spotify logout")
                            } else if settingsViewModel.extendedLoginAnimation == .failed {
                                Text("Extended Spotify login")
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
                    }
                    .disabled(![.success, .failed].contains(settingsViewModel.extendedLogin))

                    SettingsButton(text: "Clear Spotify and SponsorBlock cache") {
                        clearSpotifyCache()
                        SponsorBlockAPI.shared.clearCache()
                    } buttonLabel: {
                        Text("Clear cache")
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
