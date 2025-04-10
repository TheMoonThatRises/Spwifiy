//
//  ArtistViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/29/24.
//

import SwiftUI
import SpotifyWebAPI

class ArtistViewModel: ObservableObject {

    enum CurrentView: String, CaseIterable {
        case homeView = "Home"
        case albumView = "Albums"
        case singlesEpView = "Singles and EPs"
        case merchView = "Merch"
        case aboutView = "About"
    }

    var spotifyCache: SpotifyCache

    private var isFetchingArtistDetails: Bool = false

    @AppStorage("settings.artists.displaytype") var displayType: DisplayType = .grid

    @Published var artist: Artist
    @Published var topTracks: [Track]
    @Published var albums: [Album]

    @Published var filteredAlbums: [Album] = []
    @Published var filteredSingleEp: [Album] = []

    @Published var albumTracks: [String: [Track]] = [:]

    @Published var backgroundImageURL: URL?
    @Published var monthlyListeners: Int?
    @Published var followers: Int?
    @Published var biography: String?
    @Published var externalLinks: [(String, String)] = []

    @Published var searchText: String = ""

    @Published  var currentView: CurrentView = .homeView

    private var populateAlbumTrackCount = 25

    init(spotifyCache: SpotifyCache, artist: Artist) {
        self.spotifyCache = spotifyCache

        self.artist = artist.followers == nil ? spotifyCache[artistId: artist.id ?? ""] ?? artist : artist
        self.topTracks = spotifyCache[artistTopTracksId: artist.id ?? ""] ?? []

        self.albums = spotifyCache[artistAlbumsId: artist.id ?? ""] ?? []

        self.updateAlbumsFilters()

        Task { @MainActor in
            await self.populateAlbumTracks(fetchTracks: false)
            self.populateArtistInfo()

            if backgroundImageURL == nil {
                await self.getBackgroundArt(useCache: true)
            }
        }
    }

    @MainActor
    public func updateArtistDetails() async {
        let willUpdateArtist = artist.followers == nil
        let willUpdateAlbums = albums.isEmpty
        let willUpdateAlbumTracks = albumTracks.isEmpty || willUpdateAlbums
        let willUpdateTopTracks = willUpdateArtist || topTracks.isEmpty
        let willUpdateArtistJSONInfo = monthlyListeners == nil

        guard !isFetchingArtistDetails &&
                (
                    willUpdateAlbumTracks ||
                    willUpdateTopTracks ||
                    willUpdateArtistJSONInfo
                ) else {
            return
        }

        isFetchingArtistDetails = true

        defer {
            isFetchingArtistDetails = false
        }

        do {
            if let id = artist.id {
                if willUpdateArtist {
                    try await getArtist(artistId: id)
                }

                if willUpdateTopTracks {
                    topTracks = try await spotifyCache.fetchArtistTopTracks(artistId: id)
                }

                if willUpdateArtistJSONInfo {
                    await SpotifyScraper.shared.fetchArtistJSON(artistId: id) {
                        Task { @MainActor in
                            self.populateArtistInfo()
                        }
                    }
                }

                if willUpdateAlbums {
                    albums = (try await spotifyCache.fetchArtistAlbum(artistId: id))
                        .sorted { ($0.releaseDate ?? Date()) > ($1.releaseDate ?? Date()) }
                }

                if willUpdateAlbumTracks {
                    await populateAlbumTracks(fetchTracks: true)

                    if backgroundImageURL == nil {
                        await getBackgroundArt(useCache: false)
                    }
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
    private func getBackgroundArt(useCache: Bool) async {
        if let artistId = artist.id,
           let backgroundArt = YoutubeMusicAPI.shared.getBackgroundArtCache(artistId: artistId),
           let url = URL(string: backgroundArt) {
            withAnimation(.easeInOut) {
                backgroundImageURL = url
            }
        } else if !useCache {
            let track = albumTracks
                .sorted { one, two in
                    if one.value.first?.album != nil && two.value.first?.album != nil {
                        return (
                            albums.first { $0.id == one.key }?.releaseDate ?? Date()
                        ) > (
                            albums.first { $0.id == two.key }?.releaseDate ?? Date()
                        )
                    } else {
                        return one.value.first?.album != nil
                    }
                }
                .flatMap { $0.1 }
                .filter {
                    $0.artists?.count == 1 &&
                    $0.artists?.first?.id == artist.id
                }

            var imageURLString = await YoutubeMusicAPI.shared.getBackgroundArt(
                artistId: artist.id,
                artistName: artist.name,
                topSong: track.first?.name,
                topAlbum: track.first?.album?.name
            )

            if imageURLString == nil {
                imageURLString = await YoutubeMusicAPI.shared.getBackgroundArt(
                    artistId: artist.id,
                    artistName: artist.name,
                    topSong: nil,
                    topAlbum: nil
                )
            }

            if let imageURLString = imageURLString,
               let url = URL(string: imageURLString) {
                withAnimation(.easeInOut) {
                    backgroundImageURL = url
                }
            }
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

    private func populateArtistInfo() {
        guard let artistId = artist.id else {
            return
        }

        if let backgroundString = SpotifyScraper.shared.getArtistBackgroundBanner(artistId: artistId),
           let backgroundURL = URL(string: backgroundString) {
            withAnimation(.easeInOut) {
                backgroundImageURL = backgroundURL
            }
        }

        if let artistListeners = SpotifyScraper.shared.getArtistMonthlyListeners(artistId: artistId) {
            withAnimation(.easeInOut) {
                monthlyListeners = artistListeners
            }
        }

        if let artistFollowers = SpotifyScraper.shared.getArtistFollowers(artistId: artistId) {
            withAnimation(.easeInOut) {
                followers = artistFollowers
            }
        }

        if let artistBiography = SpotifyScraper.shared.getArtistBiography(artistId: artistId) {
            withAnimation(.easeInOut) {
                biography = artistBiography
            }
        }

        withAnimation(.easeInOut) {
            externalLinks = SpotifyScraper.shared.getArtistExternalLinks(artistId: artistId)
        }
    }

    private func onFilterChange(type: [AlbumType], albumList: inout [Album]) {
        let albumTypes = albums.filter {
            if let albumGroup = $0.albumGroup {
                return type.contains(albumGroup)
            } else {
                return false
            }
        }

        albumList = (
                searchText.isEmpty
                    ? albumTypes
                    : albumTypes.filter {
                        $0.searchText.contains(searchText.lowercased())
                    }
            )
            .sorted {
                ($0.releaseDate ?? Date()) > ($1.releaseDate ?? Date())
            }
    }

    public func onAlbumFilterChange() {
        onFilterChange(type: [.album], albumList: &filteredAlbums)
    }

    public func onSingleEpFilterChange() {
        onFilterChange(type: [.ep, .single], albumList: &filteredSingleEp)
    }

    public func updateAlbumsFilters() {
        onAlbumFilterChange()
        onSingleEpFilterChange()
    }

}
