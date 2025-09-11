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
            isLoading = true
            error = nil
            seenIds.removeAll()
            items.removeAll()
        } else {
            guard !isLoadingNext, next <= totalPages else { return }
            isLoadingNext = true
        }

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
                // Idempotent append by id to guarantee stable identity across pages
                let newUnique = page.items.filter { !self.seenIds.contains($0.id) }
                newUnique.forEach { self.seenIds.insert($0.id) }
                let combined = (next == 1) ? newUnique : self.items + newUnique
                self.items = self.applySortIfNeeded(combined)
            })
            .store(in: &cancellables)
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
        sortOrder = order
        items = applySortIfNeeded(items)
    }

    private func applySortIfNeeded(_ list: [Movie]) -> [Movie] {
        guard let order = sortOrder else { return list }
        return list.sorted(by: order)
    }
}
