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
import MoviesPersistence

@MainActor
@Observable
public final class FavoritesViewModel {
    public private(set) var items: [Movie] = []
    public private(set) var isLoading: Bool = false
    public private(set) var error: Error?
    public var sortOrder: MovieSortOrder?

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    @ObservationIgnored private let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var currentRequest: AnyCancellable?

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        startObservingFavorites()
    }

    // MARK: - View State
    public enum FavoritesViewState {
        case loading
        case error(Error)
        case empty
        case content(items: [Movie])
    }

    public var state: FavoritesViewState {
        if let error { return .error(error) }
        if isLoading && items.isEmpty { return .loading }
        if items.isEmpty { return .empty }
        return .content(items: items)
    }

    public func reload() {
        let ids = Array(favoritesStore.favoriteMovieIds)
        reload(for: ids)
    }

    private func startObservingFavorites() {
        withObservationTracking({ [weak self] in
            guard let self else { return }
            let ids = Array(self.favoritesStore.favoriteMovieIds)
            self.reload(for: ids)
        }, onChange: { [weak self] in
            DispatchQueue.main.async { self?.startObservingFavorites() }
        })
    }

    private func reload(for ids: [Int]) {
        isLoading = true
        error = nil
        guard !ids.isEmpty else { items = []; isLoading = false; return }

        // Cancel any previous request to prevent overlaps and memory leaks
        currentRequest?.cancel()
        currentRequest = nil
        cancellables.removeAll()

        // Load favorites sequentially in batches of 3 to avoid overwhelming the API
        loadFavoritesSequentially(ids: ids, batchSize: 3)
    }

    private func loadFavoritesSequentially(ids: [Int], batchSize: Int) {
        var loadedMovies: [Movie] = []
        var remainingIds = ids
        var currentBatch: [Int] = []

        // Process batches sequentially
        func processNextBatch() {
            guard !remainingIds.isEmpty else {
                // All batches processed
                self.items = self.applySortIfNeeded(loadedMovies)
                self.isLoading = false
                return
            }

            // Take next batch
            let batchEndIndex = min(batchSize, remainingIds.count)
            currentBatch = Array(remainingIds.prefix(batchEndIndex))
            remainingIds = Array(remainingIds.dropFirst(batchEndIndex))

            // Create publishers for current batch
            let publishers = currentBatch.map { repository.fetchMovieDetails(id: $0) }

            // Process batch concurrently (within batch) but sequentially between batches
            Publishers.MergeMany(publishers)
                .collect()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let err) = completion {
                        self.isLoading = false
                        self.error = err
                        return
                    }
                    // Process next batch on success
                    processNextBatch()
                }, receiveValue: { details in
                    // Map details to lightweight Movie for consistency with grid
                    let movies = details.map { Movie(
                        id: $0.id,
                        title: $0.title,
                        overview: $0.overview,
                        posterPath: $0.posterPath,
                        backdropPath: $0.backdropPath,
                        releaseDate: $0.releaseDate,
                        voteAverage: $0.voteAverage,
                        voteCount: $0.voteCount,
                        genreIds: nil,
                        genres: $0.genres
                    ) }
                    loadedMovies.append(contentsOf: movies)
                })
                .store(in: &cancellables)
        }

        // Start processing batches
        processNextBatch()
    }

    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }
    public func isFavorite(_ id: Int) -> Bool { favoritesStore.isFavorite(movieId: id) }
    public func setSortOrder(_ order: MovieSortOrder) {
        // Cancel any in-flight requests to prevent race conditions
        currentRequest?.cancel()
        currentRequest = nil

        sortOrder = order
        items = applySortIfNeeded(items)
        // Note: Favorites doesn't auto-scroll to top on sort change
        // Users can manually scroll if they want to see top results
    }

    /// Favorites uses client-side sorting only
    public var supportsServerSideSorting: Bool { false }

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
