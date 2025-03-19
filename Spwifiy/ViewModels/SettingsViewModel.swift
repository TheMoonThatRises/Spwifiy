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

}
