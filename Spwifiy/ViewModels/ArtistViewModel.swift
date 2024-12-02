//
//  ArtistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class ArtistViewModel: ObservableObject {

    var spotifyCache: SpotifyCache

    private var isFetchingArtistDetails: Bool = false

    @Published var artist: Artist
    @Published var topTracks: [Track]
    @Published var albums: [Album]

    @Published var albumTracks: [String: [Track]] = [:]

    @Published var backgroundImageURL: URL?
    @Published var monthlyListeners: Int?

    @Published var searchText: String = ""

    private var populateAlbumTrackCount = 10

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self.spotifyCache = spotifyCache

        self.artist = artist.followers == nil ? spotifyCache[artistId: artist.id ?? ""] ?? artist : artist
        self.topTracks = spotifyCache[artistTopTracksId: artist.id ?? ""] ?? []

        self.albums = spotifyCache[artistAlbumsId: artist.id ?? ""] ?? []

        Task { @MainActor in
            await self.populateAlbumTracks(fetchTracks: false)

            if !self.topTracks.isEmpty {
                await self.getBackgroundArt()
            }

            self.monthlyListeners = await SpotifyScraper.shared.getArtistMonthlyListeners(artistId: artist.id ?? "")
        }
    }

    @MainActor
    public func updateArtistDetails() async {
        let willUpdateArtist = artist.followers == nil
        let willUpdateAlbums = albums.isEmpty
        let willUpdateAlbumTracks = true
        let willUpdateTopTracks = willUpdateArtist || topTracks.isEmpty
        let willUpdateMonthlyListeners = monthlyListeners == nil

        guard !isFetchingArtistDetails &&
                (
                    willUpdateAlbumTracks ||
                    willUpdateTopTracks ||
                    willUpdateMonthlyListeners
                ) else {
            return
        }

        do {
            if let id = artist.id {
                if willUpdateArtist {
                    try await getArtist(artistId: id)
                }

                if willUpdateAlbums {
                    albums = try await spotifyCache.fetchArtistAlbum(artistId: id)
                }

                if willUpdateAlbumTracks {
                    await populateAlbumTracks(fetchTracks: true)

                    await getBackgroundArt()
                }

                if willUpdateTopTracks {
                    topTracks = try await spotifyCache.fetchArtistTopTracks(artistId: id)
                }

                if willUpdateMonthlyListeners {
                    await getMonthlyListeners(artistId: id)
                }
            }
        } catch {
            print("unable to refresh artist details: \(error)")
        }
    }

    @MainActor
    public func populateNextAlbumChunk() async {
        populateAlbumTrackCount = min(populateAlbumTrackCount + 10, albums.count)

        await populateAlbumTracks(fetchTracks: true)
    }

    @MainActor
    private func getArtist(artistId: String) async throws {
        if let artistCache = spotifyCache[artistId: artistId] {
            artist = artistCache
        } else {
            artist = try await spotifyCache.fetchArtist(artistId: artistId)
        }
    }

    @MainActor
    private func getBackgroundArt() async {
        if let artistId = artist.id,
           let backgroundArt = YoutubeMusicAPI.shared.getBackgroundArtCache(artistId: artistId),
           let url = URL(string: backgroundArt) {
            withAnimation(.easeInOut) {
                backgroundImageURL = url
            }
        } else {
            let track = albumTracks
                .flatMap { $0.1 }
                .filter { $0.artists?.count == 1 && $0.artists?.first?.id == artist.id }
                .first

            let imageURLString = await YoutubeMusicAPI.shared.getBackgroundArt(
                artistId: artist.id,
                artistName: artist.name,
                topSong: track?.name,
                topAlbum: track?.album?.name
            )

            if let imageURLString = imageURLString,
               let url = URL(string: imageURLString) {
                withAnimation(.easeInOut) {
                    backgroundImageURL = url
                }
            }
        }
    }

    @MainActor
    private func getMonthlyListeners(artistId: String) async {
        let listeners = await SpotifyScraper.shared.getArtistMonthlyListeners(artistId: artistId)

        withAnimation(.easeInOut) {
            monthlyListeners = listeners
        }
    }

    @MainActor
    private func populateAlbumTracks(fetchTracks: Bool) async {
        let albumIds = Array(albums.compactMap { $0.id }.prefix(populateAlbumTrackCount))

        if fetchTracks {
            do {
                albumTracks = try await spotifyCache.fetchAllAlbumTracks(albumIds: albumIds)
            } catch {
                print("unable to update album tracks: \(error)")
            }
        } else {
            albumTracks = spotifyCache.getAllAlbumTracks(albumIds: albumIds)
        }
    }

}
