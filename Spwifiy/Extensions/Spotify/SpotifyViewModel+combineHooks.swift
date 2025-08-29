//
//  SpotifyViewModel+combineHooks.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 8/29/25.
//

extension SpotifyViewModel {

    internal func authorizationManagerDidChange() {
        isAuthorized = spotify.authorizationManager.isAuthorized()

        do {
            let authManagerData = try encoder.encode(spotify.authorizationManager)

            keychain[data: SpotifyViewModel.authorizationManagerKey] = authManagerData
        } catch {
            print("unable to store auth manager state")
        }
    }

    internal func authorizationManagerDidDeauthorize() {
        isAuthorized = false

        do {
            try keychain.remove(SpotifyViewModel.authorizationManagerKey)
        } catch {
            print("unable to remove unauthorized manager")
        }
    }

}
