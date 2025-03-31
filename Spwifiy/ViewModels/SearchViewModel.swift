//
//  SearchViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/19/25.
//

import SwiftUI
import SpotifyWebAPI

class SearchViewModel: ObservableObject {

    private static var searchCategories: [IDCategory] = [
        .album,
        .artist,
        .playlist,
        .track,
        .show,
        .episode,
        .audiobook
//        .genre,
//        .user
    ]

    private var searchTask: Task<Void?, Never>?

    @Published var searchResult: SearchResult?
    @Published var isSearching: Bool = false

    var showFlags: Int {
        CollectionShowFlags.noSongListTitle | CollectionShowFlags.showAlbum
    }

    public func search(spotifyViewModel: SpotifyViewModel, query: String) {
        if let searchTask = searchTask {
            searchTask.cancel()
        }

        if query.isEmpty {
            searchResult = nil

            return
        }

        isSearching = true

        searchTask = Task {
            defer {
                searchTask = nil
            }

            do {
                try? await Task.sleep(for: .seconds(1))

                let result = try await spotifyViewModel.spotifyRequest {
                    spotifyViewModel.spotify.search(
                        query: query,
                        categories: SearchViewModel.searchCategories)
                }

                Task { @MainActor in
                    isSearching = false
                    searchResult = result
                }
            } catch {
                print(error)
            }
        }
    }

}
