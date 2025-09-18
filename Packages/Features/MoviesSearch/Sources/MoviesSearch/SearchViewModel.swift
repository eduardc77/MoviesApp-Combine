//
//  SearchViewModel.swift
//  MoviesSearch
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain

@MainActor
@Observable
public final class SearchViewModel {
    public var items: [Movie] = []
    public var isLoading = false
    public var isLoadingNext = false
    public var error: Error?
    public var query: String = "" {
        didSet { querySubject.send(query) }
    }

    @ObservationIgnored private var page = 1
    @ObservationIgnored private var totalPages = 1
    @ObservationIgnored private var currentRequest: AnyCancellable?

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    @ObservationIgnored private let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private let querySubject = PassthroughSubject<String, Never>()

    public enum Trigger {
        case debounce
        case submit
    }

    var isQueryShort: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).count < 3
    }

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        // Debounced type-ahead (>=3 chars). Set loading pre-debounce for responsiveness.
        querySubject
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Trim whitespace
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] trimmed in
                guard let self else { return }
                if trimmed.isEmpty {
                    self.cancelAndClear() // Clear when empty
                } else if trimmed.count >= 3 {
                    self.error = nil
                    self.isLoading = true // Show loading immediately
                }
            })
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if !self.isQueryShort {
                    self.search(reset: true, trigger: .debounce)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - View State
    public enum SearchViewState {
        case idle // no query yet or too short
        case loading
        case error(Error)
        case empty // valid query but no results
        case content(items: [Movie], isLoadingNext: Bool)
    }

    public var state: SearchViewState {
        switch true {
        case error != nil:
            return .error(error!)
        case isLoading:
            return .loading
        case items.isEmpty && isQueryShort:
            return .idle
        case items.isEmpty:
            return .empty
        default:
            return .content(items: items, isLoadingNext: isLoadingNext)
        }
    }

    /// Async refresh method for pull-to-refresh
    public func refresh() async {
        guard !query.isEmpty else { return }
        search(reset: true, trigger: .submit)
    }

    public func search(reset: Bool = true, trigger: Trigger) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            items = []
            return
        }
        if trigger == .debounce {
            guard !isQueryShort else { return }
        }
        let next = reset ? 1 : page + 1
        if reset {
            prepareForNewSearch()
        } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

        currentRequest?.cancel()
        currentRequest = repository.searchMovies(query: trimmed, page: next)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isLoadingNext = false
                self.currentRequest = nil
                if case .failure(let error) = completion { self.error = error }
            }, receiveValue: { [weak self] page in
                guard let self else { return }
                self.page = page.page
                self.totalPages = page.totalPages
                // Prevent duplicates across pages for a single query
                let existing = Set(self.items.map(\.id))
                let newItems = page.items.filter { !existing.contains($0.id) }
                self.items.append(contentsOf: newItems)
            })
    }

    public var canLoadMore: Bool { page < totalPages }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }
    public func toggleFavorite(_ id: Int) {
        if let movie = items.first(where: { $0.id == id }) {
            favoritesStore.addToFavorites(movie: movie)
        }
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 3, 0) else { return }
        search(reset: false, trigger: .submit)
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

    /// Prepares state for a new search (shows loading)
    private func prepareForNewSearch() {
        resetState(startLoading: true)
    }

    /// Cancels ongoing requests and clears state (stops loading)
    private func cancelAndClear() {
        resetState(startLoading: false)
    }
}
