//
//  HomeViewModel.swift
//  MoviesHome
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
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

    @ObservationIgnored private var page = 1
    @ObservationIgnored private var totalPages = 1

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    @ObservationIgnored private let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var currentRequest: AnyCancellable?
    @ObservationIgnored private var lastRequestedCount: Int = 0
    @ObservationIgnored private var isInitialLoad: Bool = true

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
        if let error { return .error(error) }
        if isLoading && items.isEmpty { return .loading }
        if items.isEmpty { return .empty }
        return .content(items: items, isLoadingNext: isLoadingNext)
    }


    public func load(reset: Bool = true) {
        let next = reset ? 1 : page + 1
#if DEBUG
        print("HOME REQUEST reset:\(reset) next:\(next) cat:\(category) sort:\(String(describing: sortOrder))")
#endif

        if reset {
            // If a reset load is already in progress, avoid starting another
            if isLoading { return }
            resetState(startLoading: true)
        } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

        let pagePublisher: AnyPublisher<MoviePage, Error> = {
            if let sortOrder = sortOrder {
                return repository.fetchMovies(type: category, page: next, sortBy: sortOrder)
            } else {
                return repository.fetchMovies(type: category, page: next)
            }
        }()

        currentRequest = pagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isLoadingNext = false
                self.currentRequest = nil
                if case .failure(let err) = completion { self.error = err }
            }, receiveValue: { [weak self] page in
                guard let self else { return }
#if DEBUG
                print("HOME RESPONSE page:\(page.page) items:\(page.items.count)")
#endif
                self.page = page.page
                self.totalPages = page.totalPages
                let existing = Set(self.items.map(\.id))
                let newItems = page.items.filter { !existing.contains($0.id) }
                self.items.append(contentsOf: newItems)
                self.lastRequestedCount = self.items.count
            })
    }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }
    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }

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
        lastRequestedCount = 0
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 6, 0) else { return }
        load(reset: false)
    }

    // MARK: - Category switching
    public func setCategory(_ newCategory: MovieType) {
        guard newCategory != category else { return }
        category = newCategory
        load(reset: true)
    }
}
