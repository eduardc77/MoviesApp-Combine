//
//  FavoritesViewModel.swift
//  MoviesFavorites
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import Observation
import MoviesDomain

@MainActor
@Observable
public final class FavoritesViewModel {
    public private(set) var items: [Movie] = []
    public private(set) var isLoading: Bool = false
    public private(set) var error: Error?
    public var sortOrder: MovieSortOrder?

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    public let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var currentRequest: AnyCancellable?
    /// Tracks if sort order was just changed (for scroll-to-top UX)
    public var didChangeSortOrder = false

    /// In-memory cache for movie details to avoid redundant network requests
    @ObservationIgnored private var movieCache: [Int: Movie] = [:]

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    // MARK: - View State
    public enum FavoritesViewState {
        case loading
        case error(Error)
        case empty
        case content(items: [Movie])
    }

    public var state: FavoritesViewState {
        switch true {
        case error != nil:
            return .error(error!)
        case isLoading && items.isEmpty:
            return .loading
        case items.isEmpty:
            return .empty
        default:
            return .content(items: items)
        }
    }

    /// Clean async refresh method for pull-to-refresh
    public func refresh() async {
        let ids = Array(favoritesStore.favoriteMovieIds)
        if !ids.isEmpty {
            // Force refresh all cached movies from network
            movieCache.removeAll()
            fetchMovies(for: ids)
        } else {
            items = []
            isLoading = false
        }
    }

    public func reload() {
        favoritesDidChange()
    }

    /// Called by the View when it detects changes via onChange
    /// This allows the View to trigger reloads when the store's favorites change
    public func favoritesDidChange() {
        let ids = Array(favoritesStore.favoriteMovieIds)

        if ids.isEmpty {
            // Handle empty state immediately - no network call needed
            items = []
            isLoading = false
            error = nil
            return
        }

        // Check which movies we need to fetch
        let cachedIds = Set(movieCache.keys)
        let newIds = Set(ids).subtracting(cachedIds)

        if newIds.isEmpty {
            // All movies are cached - update items immediately
            items = ids.compactMap { movieCache[$0] }
            items = applySortIfNeeded(items)
            isLoading = false
        } else {
            // Need to fetch some movies
            isLoading = true
            fetchMovies(for: Array(newIds))
        }
    }

    /// Fetches only the missing movies and updates cache
    private func fetchMovies(for ids: [Int]) {
        guard !ids.isEmpty else { return }

        isLoading = true
        error = nil

        // Cancel any previous request to prevent overlaps and memory leaks
        currentRequest?.cancel()
        currentRequest = nil
        cancellables.removeAll()

        // Load only the requested movies concurrently
        let cancellable = Publishers.MergeMany(ids.map { repository.fetchMovieDetails(id: $0) })
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.currentRequest = nil
                if case .failure(let err) = completion {
                    self.error = err
                }
            }, receiveValue: { [weak self] details in
                guard let self else { return }

                // Cache the fetched movies
                for detail in details {
                    let movie = Movie(
                        id: detail.id,
                        title: detail.title,
                        overview: detail.overview,
                        posterPath: detail.posterPath,
                        backdropPath: detail.backdropPath,
                        releaseDate: detail.releaseDate,
                        voteAverage: detail.voteAverage,
                        voteCount: detail.voteCount,
                        genres: detail.genres
                    )
                    self.movieCache[detail.id] = movie
                }

                // Update items with all cached movies in correct order
                let allFavoriteIds = Array(self.favoritesStore.favoriteMovieIds)
                self.items = allFavoriteIds.compactMap { self.movieCache[$0] }
                self.items = self.applySortIfNeeded(self.items)
            })

        currentRequest = cancellable
        cancellable.store(in: &cancellables)
    }

    /// Legacy method - kept for compatibility but uses new caching logic
    private func reload(for ids: [Int]) {
        // This method is now replaced by fetchMovies, but kept for any external calls
        fetchMovies(for: ids)
    }

    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }
    public func isFavorite(_ id: Int) -> Bool { favoritesStore.isFavorite(movieId: id) }

    public func setSortOrder(_ order: MovieSortOrder) {
        // Mark that sort changed for scroll-to-top UX
        didChangeSortOrder = true
        sortOrder = order
        // Re-sort cached items without network calls
        items = applySortIfNeeded(items)
    }
    
    private func applySortIfNeeded(_ list: [Movie]) -> [Movie] {
        guard let order = sortOrder else { return list }

        // Use stable sort to maintain relative order for equal elements
        return list.sorted { movie1, movie2 in
            switch order {
            case .ratingAscending:
                return movie1.voteAverage < movie2.voteAverage
            case .ratingDescending:
                return movie1.voteAverage > movie2.voteAverage
            case .releaseDateAscending:
                return movie1.releaseDate < movie2.releaseDate
            case .releaseDateDescending:
                return movie1.releaseDate > movie2.releaseDate
            }
        }
    }
}
