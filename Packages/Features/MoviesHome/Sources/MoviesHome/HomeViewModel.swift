//
//  HomeViewModel.swift
//  MoviesHome
//

import Foundation
import Combine
import Observation
import MoviesDomain
import MoviesPersistence

@MainActor
@Observable
public final class HomeViewModel {
    public var items: [Movie] = []
    public var isLoading = false
    public var isLoadingNext = false
    public var error: Error?
    public var sortOrder: MovieSortOrder?
    public var category: MovieType = .nowPlaying

    private var page = 1
    private var totalPages = 1
    private var seenIds = Set<Int>()

    private let repository: MovieRepositoryProtocol
    private let favoritesStore: FavoritesStore
    private var cancellables = Set<AnyCancellable>()
    private var currentRequest: AnyCancellable?

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStore) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    public func load(reset: Bool = true) {
        let next = reset ? 1 : page + 1

        if reset {
            performFullReset()
        } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

        // Always use server-side sorting when sortOrder is set
        if let sortOrder = sortOrder {
            // Use server-side sorting via discover endpoint
            repository.fetchMovies(type: category, page: next, sortBy: sortOrder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    self.isLoadingNext = false
                    if case .failure(let err) = completion { self.error = err }
                }, receiveValue: { [weak self] page in
                    guard let self else { return }
                    self.page = page.page
                    self.totalPages = page.totalPages

                    // Add all movies from this page, then deduplicate (server sorting already applied)
                    let allMovies = self.items + page.items

                    // Deduplicate by ID while preserving order stability
                    var uniqueMovies: [Movie] = []
                    var seenInThisBatch = Set<Int>()

                    for movie in allMovies {
                        if !seenInThisBatch.contains(movie.id) {
                            uniqueMovies.append(movie)
                            seenInThisBatch.insert(movie.id)
                        }
                    }

                    self.items = uniqueMovies

                    // Update seenIds for future API call prevention
                    page.items.forEach { self.seenIds.insert($0.id) }
                })
                .store(in: &cancellables)
        } else {
            // No sorting: Use traditional endpoints but could still benefit from server-side default sorting
            repository.fetchMovies(type: category, page: next)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    self.isLoadingNext = false
                    if case .failure(let err) = completion { self.error = err }
                    }, receiveValue: { [weak self] page in
                        guard let self else { return }
                        self.page = page.page
                        self.totalPages = page.totalPages

                        // Add all movies from this page, then deduplicate
                        let allMovies = self.items + page.items

                        // Deduplicate by ID while preserving order stability
                        var uniqueMovies: [Movie] = []
                        var seenInThisBatch = Set<Int>()

                        for movie in allMovies {
                            if !seenInThisBatch.contains(movie.id) {
                                uniqueMovies.append(movie)
                                seenInThisBatch.insert(movie.id)
                            }
                        }

                        self.items = uniqueMovies

                        // Update seenIds for future API call prevention
                        page.items.forEach { self.seenIds.insert($0.id) }
                    })
                .store(in: &cancellables)
        }
    }

    /// Determines if server-side sorting is supported for the current category
    public var supportsServerSideSorting: Bool {
        supportsServerSideSorting(for: category)
    }

    /// Determines if server-side sorting is supported for the given movie type
    private func supportsServerSideSorting(for type: MovieType) -> Bool {
        // All movie types support server-side sorting via /discover/movie
        return true
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 6, 0) else { return }
        load(reset: false)
    }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }
    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }

    public func setSortOrder(_ order: MovieSortOrder) {
        // Store the previous sort order to detect changes
        sortOrder = order

        // Always reset and reload when sorting changes (including when sorting is first applied)
        resetPagination()

        load(reset: true)
    }

    public func clearSortOrder() {
        if sortOrder != nil {
            sortOrder = nil
            resetPagination()
            load(reset: true)
        }
    }

    private func resetPagination() {
        page = 1
        totalPages = 1
        seenIds.removeAll()
        items.removeAll()
        isLoading = false
        isLoadingNext = false
        error = nil
        // Don't reset scrollToTopTrigger here as it should be controlled explicitly
    }

    /// Performs a full state reset for fresh loads
    private func performFullReset() {
        isLoading = true
        error = nil
        seenIds.removeAll()
        items.removeAll()
        page = 1  // Reset pagination counters
        totalPages = 1
    }

    private func applySortIfNeeded(_ list: [Movie]) -> [Movie] {
        guard let order = sortOrder else { return list }
        return list.sorted(by: order)
    }
}
