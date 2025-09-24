//
//  FavoritesViewModel.swift
//  MoviesFavorites
//
//  Created by User on 9/10/25.
//

import Observation
import Combine
import MoviesDomain

@MainActor
@Observable
public final class FavoritesViewModel {
    public private(set) var items: [Movie] = []
    public private(set) var isLoading: Bool = false
    public private(set) var isLoadingNext: Bool = false
    public private(set) var error: Error?
    public var sortOrder: MovieSortOrder? = .recentlyAdded

    public let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var pageCursor: FavoritesPageCursor?
    @ObservationIgnored private var pageSize = FavoritesPagingDefaults.pageSize
    @ObservationIgnored private var previousFavoriteIds: Set<Int>? = nil
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []

    public init(favoritesStore: FavoritesStoreProtocol) {
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

    /// async refresh method for pull-to-refresh
    public func refresh() async { load(reset: true) }

    public func reload() { loadAll() }

    /// Called by the View when it detects changes via onChange
    /// Apply incremental updates for best animations and performance
    public func favoritesDidChange() {
        if isLoading { return }
        let currentFavoriteIds = favoritesStore.favoriteMovieIds
        guard let prev = previousFavoriteIds else {
            previousFavoriteIds = currentFavoriteIds
            return
        }
        let addedIds = currentFavoriteIds.subtracting(prev)
        let removedIds = prev.subtracting(currentFavoriteIds)
        if addedIds.isEmpty && removedIds.isEmpty { return }

        if !removedIds.isEmpty { items.removeAll { removedIds.contains($0.id) } }

        if !addedIds.isEmpty {
            var additions: [Movie] = []
            for id in addedIds { if let d = favoritesStore.getFavoriteDetails(movieId: id) { additions.append(d.asMovie) } }
            batchInsert(movies: additions, order: sortOrder)
        }

        previousFavoriteIds = currentFavoriteIds
    }

    private func fetchMovieSync(movieId: Int) -> Movie? {
        // Get the specific movie details by ID (this is the correct way)
        guard let details = favoritesStore.getFavoriteDetails(movieId: movieId) else {
            return nil
        }
        return details.asMovie
    }

    private func sortMovies(_ movies: [Movie], for order: MovieSortOrder) -> [Movie] {
        switch order {
        case .popularityAscending:
            return movies.sorted { lhs, rhs in
                if lhs.popularity == rhs.popularity { return lhs.id < rhs.id }
                return lhs.popularity < rhs.popularity
            }
        case .popularityDescending:
            return movies.sorted { lhs, rhs in
                if lhs.popularity == rhs.popularity { return lhs.id < rhs.id }
                return lhs.popularity > rhs.popularity
            }
        case .ratingAscending:
            return movies.sorted { lhs, rhs in
                if lhs.voteAverage == rhs.voteAverage { return lhs.id < rhs.id }
                return lhs.voteAverage < rhs.voteAverage
            }
        case .ratingDescending:
            return movies.sorted { lhs, rhs in
                if lhs.voteAverage == rhs.voteAverage { return lhs.id < rhs.id }
                return lhs.voteAverage > rhs.voteAverage
            }
        case .releaseDateAscending:
            return movies.sorted { lhs, rhs in
                if lhs.releaseDate == rhs.releaseDate { return lhs.id < rhs.id }
                return lhs.releaseDate < rhs.releaseDate
            }
        case .releaseDateDescending:
            return movies.sorted { lhs, rhs in
                if lhs.releaseDate == rhs.releaseDate { return lhs.id < rhs.id }
                return lhs.releaseDate > rhs.releaseDate
            }
        case .recentlyAdded:
            // stable fallback
            return movies.sorted { $0.id < $1.id }
        }
    }

    private func batchInsert(movies: [Movie], order: MovieSortOrder?) {
        guard !movies.isEmpty else { return }
        var newItems = self.items
        let uniqueAdds = movies.filter { movie in !newItems.contains(where: { $0.id == movie.id }) }
        guard !uniqueAdds.isEmpty else { return }

        if let order {
            if order == .recentlyAdded {
                newItems.insert(contentsOf: uniqueAdds, at: 0)
            } else {
                let sortedAdds = sortMovies(uniqueAdds, for: order)
                for movie in sortedAdds {
                    let idx = newItems.firstIndex { existing in shouldInsertBefore(movie, existing, sortOrder: order) } ?? newItems.count
                    newItems.insert(movie, at: idx)
                }
            }
        } else {
            newItems.insert(contentsOf: uniqueAdds, at: 0)
        }

        self.items = newItems
    }

    private func loadAll() {
        load(reset: true)
    }

    private func insertMovie(_ movie: Movie, order: MovieSortOrder?) {
        guard let order else {
            items.insert(movie, at: 0)
            return
        }
        if order == .recentlyAdded {
            items.insert(movie, at: 0)
            return
        }
        let idx = items.firstIndex { existing in shouldInsertBefore(movie, existing, sortOrder: order) } ?? items.count
        items.insert(movie, at: idx)
    }

    private func shouldInsertBefore(_ newMovie: Movie, _ existingMovie: Movie, sortOrder: MovieSortOrder) -> Bool {
        switch sortOrder {
        case .popularityAscending:
            return newMovie.popularity < existingMovie.popularity
        case .popularityDescending:
            return newMovie.popularity > existingMovie.popularity
        case .ratingAscending:
            return newMovie.voteAverage < existingMovie.voteAverage
        case .ratingDescending:
            return newMovie.voteAverage > existingMovie.voteAverage
        case .releaseDateAscending:
            return newMovie.releaseDate < existingMovie.releaseDate
        case .releaseDateDescending:
            return newMovie.releaseDate > existingMovie.releaseDate
        case .recentlyAdded:
            return false
        }
    }

    private func load(reset: Bool) {
        if reset {
            isLoading = true
            isLoadingNext = false
            error = nil
            items = []
            pageCursor = nil
        } else {
            guard !isLoadingNext else { return }
            isLoadingNext = true
        }

        let effectiveOrder = sortOrder ?? .recentlyAdded
        if reset {
            favoritesStore
                .fetchFirstPage(sortOrder: effectiveOrder, pageSize: pageSize)
                .sink { [weak self] page in
                    guard let self else { return }
                    self.items = page.items
                    self.pageCursor = page.cursor
                    self.isLoading = false
                    self.previousFavoriteIds = self.favoritesStore.favoriteMovieIds
                }
                .store(in: &cancellables)
        } else if let cursor = pageCursor {
            favoritesStore
                .fetchNextPage(cursor: cursor, pageSize: pageSize)
                .sink { [weak self] next in
                    guard let self else { return }
                    if !next.items.isEmpty {
                        let existing = Set(self.items.map { $0.id })
                        let newOnes = next.items.filter { !existing.contains($0.id) }
                        self.items.append(contentsOf: newOnes)
                    }
                    self.pageCursor = next.cursor
                    self.isLoadingNext = false
                }
                .store(in: &cancellables)
        } else {
            isLoadingNext = false
        }
    }

    public func toggleFavorite(_ id: Int) {
        _ = favoritesStore.toggleFavorite(movieId: id, in: items)
    }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.isFavorite(movieId: id) }

    public func setSortOrder(_ order: MovieSortOrder) {
        sortOrder = order
        load(reset: true)
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let currentItem,
              let tailId = items.last?.id,
              currentItem.id == tailId,
              pageCursor != nil,
              !isLoadingNext else { return }
        load(reset: false)
    }
}
