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
    @Published public var sortOrder: MovieSortOrder?
    @Published public var query: String = ""

    private var page = 1
    private var totalPages = 1

    private let repository: MovieRepositoryProtocol
    private let favoritesStore: FavoritesStore
    private var cancellables = Set<AnyCancellable>()

    var isQueryShort: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).count < 3
    }

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStore) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        // Debounced type-ahead with guardrails (>=3 chars, 700ms pause)
        $query
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] trimmed in
                guard let self else { return }
                if trimmed.isEmpty {
                    self.reset()
                } else if trimmed.count >= 3 {
                    self.query = trimmed
                    self.search(reset: true)
                }
            }
            .store(in: &cancellables)
    }

    public func search(reset: Bool = true) {
        guard !query.isEmpty else {
            items = []
            return
        }
        let next = reset ? 1 : page + 1
        if reset { isLoading = true; error = nil } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

        repository.searchMovies(query: query, page: next)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isLoadingNext = false
                if case .failure(let error) = completion { self.error = error }
            }, receiveValue: { [weak self] page in
                guard let self else { return }
                self.page = page.page
                self.totalPages = page.totalPages
                let combined = (next == 1) ? page.items : self.items + page.items
                self.items = self.applySortIfNeeded(combined)
            })
            .store(in: &cancellables)
    }

    public func loadNextIfNeeded(currentItem: Movie?) {
        guard let id = currentItem?.id,
              let idx = items.firstIndex(where: { $0.id == id }),
              idx >= max(items.count - 6, 0) else { return }
        search(reset: false)
    }

    public func isFavorite(_ id: Int) -> Bool { favoritesStore.favoriteMovieIds.contains(id) }
    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }
    public func setSortOrder(_ order: MovieSortOrder) { sortOrder = order; items = applySortIfNeeded(items) }

    private func applySortIfNeeded(_ list: [Movie]) -> [Movie] {
        guard let order = sortOrder else { return list }
        return list.sorted(by: order)
    }

    private func reset() {
        items = []
        page = 1
        totalPages = 1
        isLoading = false
        isLoadingNext = false
        error = nil
    }
}
