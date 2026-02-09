//
//  SettingsViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/18/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {

    @AppStorage("settings.playback.explicit") var playExplicit: Bool = true

    @AppStorage("settings.misc.discordrpc") var displayDiscordRPC: Bool = true

    @AppStorage("settings.misc.extended_login") var extendedLogin: SpotifyAuthManager.AuthStatus = .failed {
        willSet {
            Task { @MainActor in
                withAnimation(.defaultAnimation) {
                    extendedLoginAnimation = newValue
                }
            }
        }
    }

    @Published var extendedLoginAnimation: SpotifyAuthManager.AuthStatus = .failed {
        didSet {
            displayExtendedLoginSheet = extendedLoginAnimation == .inProcess
        }
    }
    @Published var displayExtendedLoginSheet: Bool = false

}
