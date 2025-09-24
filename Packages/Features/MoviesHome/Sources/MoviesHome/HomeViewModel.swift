//
//  HomeViewModel.swift
//  MoviesHome
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import SharedModels
import MoviesDomain
import AppLog

@MainActor
@Observable
public final class HomeViewModel {
    public var items: [Movie] = []
    public var isLoading = false
    public var isLoadingNext = false
    public var error: Error?
    public var sortOrder: MovieSortOrder?
    public var category: MovieType = .nowPlaying

    @ObservationIgnored private var page = 1
    @ObservationIgnored private var totalPages = 1

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    @ObservationIgnored private let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var currentRequest: AnyCancellable?

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    // MARK: - View State
    public enum HomeViewState {
        case loading
        case error(Error)
        case empty
        case content(items: [Movie], isLoadingNext: Bool)
    }

    public var state: HomeViewState {
        switch true {
        case error != nil:
            return .error(error!)
        case isLoading && items.isEmpty:
            return .loading
        case items.isEmpty:
            return .empty
        default:
            return .content(items: items, isLoadingNext: isLoadingNext)
        }
    }

    /// Async refresh method for pull-to-refresh
    public func refresh() async {
        AppLog.home.info("HOME PULL-TO-REFRESH: \(category)")
        // Reset and reload data
        load(reset: true)
    }

    public func load(reset: Bool = true) {
        let next = reset ? 1 : page + 1
        AppLog.home.info("HOME REQUEST reset:\(reset) next:\(next) cat:\(category) sort:\(String(describing: self.sortOrder))")

        if reset {
            // If a reset load is already in progress, avoid starting another
            if isLoading { return }
            resetState(startLoading: true)
        } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

        // Use user-selected sort order or default for category
        let effectiveSortOrder = sortOrder ?? getDefaultSortOrder(for: category)

        let pagePublisher = repository.fetchMovies(
            type: category,
            page: next,
            sortBy: effectiveSortOrder
        )

        currentRequest = pagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isLoadingNext = false
                self.currentRequest = nil
                if case .failure(let err) = completion {
                    if (err is CancellationError) { return }
                    if let urlError = err as? URLError, urlError.code == .cancelled { return }
                    self.error = err
                }
            }, receiveValue: { [weak self] page in
                guard let self else { return }

                AppLog.home.info("HOME RESPONSE page:\(page.page) items:\(page.items.count)")

                // Process pagination
                self.page = page.page
                self.totalPages = page.totalPages

                // Handle duplicates and append new items
                let existing = Set(self.items.map(\.id))
                let newItems = page.items.filter { !existing.contains($0.id) }
                self.items.append(contentsOf: newItems)
            })
    }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }

    public func toggleFavorite(_ id: Int) {
        _ = favoritesStore.toggleFavorite(movieId: id, in: items)
    }

    public func setSortOrder(_ order: MovieSortOrder) {
        // Store the previous sort order to detect changes
        sortOrder = order

        // Always reload when sorting changes
        load(reset: true)
    }

    public func clearSortOrder() {
        if sortOrder != nil {
            sortOrder = nil
            load(reset: true)
        }
    }

    /// Resets state and manages loading status
    private func resetState(startLoading: Bool = false) {
        // Cancel any in-flight requests to prevent memory leaks
        currentRequest?.cancel()
        currentRequest = nil

        // Reset all state
        isLoading = startLoading
        isLoadingNext = false
        error = nil
        items.removeAll()
        page = 1
        totalPages = 1
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 3, 0) else { return }
        load(reset: false)
    }

    // MARK: - Helpers
    private func getDefaultSortOrder(for category: MovieType) -> MovieSortOrder {
        switch category {
        case .popular:
            return .popularityDescending
        case .topRated:
            return .ratingDescending
        case .nowPlaying, .upcoming:
            return .popularityDescending  // Default to popularity for time-based categories
        }
    }

    // MARK: - Category switching
    public func setCategory(_ newCategory: MovieType) {
        guard newCategory != category else { return }
        category = newCategory
        load(reset: true)
    }
}
