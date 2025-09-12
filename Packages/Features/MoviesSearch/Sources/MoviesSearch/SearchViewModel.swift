//
//  SearchViewModel.swift
//  MoviesSearch
//

import Foundation
import Combine
import Observation
import MoviesDomain
import MoviesPersistence

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published public var items: [Movie] = []
    @Published public var isLoading = false
    @Published public var isLoadingNext = false
    @Published public var error: Error?
    @Published public var query: String = ""

    private var page = 1
    private var totalPages = 1
    private var currentRequest: AnyCancellable?

    private let repository: MovieRepositoryProtocol
    private let favoritesStore: FavoritesStore
    private var cancellables = Set<AnyCancellable>()

    public enum Trigger {
        case debounce
        case submit
    }

    var isQueryShort: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).count < 3
    }

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStore) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        // Debounced type-ahead with guardrails (>=3 chars)
        $query
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] trimmed in
                guard let self else { return }

                if trimmed.isEmpty {
                    self.reset()
                } else if trimmed.count >= 3 {
                    self.search(reset: true, trigger: .debounce)
                }
            }
            .store(in: &cancellables)
    }

    public func search(reset: Bool = true, trigger: Trigger) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            items = []
            return
        }
        if trigger == .debounce {
            guard trimmed.count >= 3 else { return }
        }
        let next = reset ? 1 : page + 1
        if reset {
            performFullReset()
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

                // Simply append the new movies
                self.items.append(contentsOf: page.items)
            })
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 6, 0) else { return }
        search(reset: false, trigger: .submit)
    }

    public var canLoadMore: Bool { page < totalPages }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }
    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }


    /// Performs a full state reset for fresh searches
    private func performFullReset() {
        // Full reset: clear everything and start fresh
        isLoading = true
        error = nil
        items.removeAll()
        page = 1  // Reset pagination counters
        totalPages = 1
    }

    private func reset() {
        // Cancel any in-flight requests to prevent memory leaks
        currentRequest?.cancel()
        currentRequest = nil

        items.removeAll()
        page = 1
        totalPages = 1
        isLoading = false
        isLoadingNext = false
        error = nil
    }
}
