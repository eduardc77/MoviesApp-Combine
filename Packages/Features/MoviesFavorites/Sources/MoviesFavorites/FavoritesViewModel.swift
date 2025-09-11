//
//  FavoritesViewModel.swift
//  MoviesFavorites
//

import Foundation
import Combine
import MoviesDomain
import MoviesPersistence

@MainActor
public final class FavoritesViewModel: ObservableObject {
    @Published public private(set) var items: [Movie] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var error: Error?
    @Published public var sortOrder: MovieSortOrder?

    private let repository: MovieRepositoryProtocol
    private let favoritesStore: FavoritesStore
    private var cancellables = Set<AnyCancellable>()

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStore) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    public func reload() {
        let ids = Array(favoritesStore.getFavoriteMovieIds())
        isLoading = true
        error = nil
        guard !ids.isEmpty else { items = []; isLoading = false; return }

        let publishers = ids.map { repository.fetchMovieDetails(id: $0).mapError { $0 }.eraseToAnyPublisher() }
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let err) = completion { self.error = err }
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
                self.items = self.applySortIfNeeded(movies)
            })
            .store(in: &cancellables)
    }

    public func toggleFavorite(_ id: Int) { favoritesStore.toggleFavorite(movieId: id) }
    public func isFavorite(_ id: Int) -> Bool { favoritesStore.getFavoriteMovieIds().contains(id) }
    public func setSortOrder(_ order: MovieSortOrder) { sortOrder = order; items = applySortIfNeeded(items) }

    private func applySortIfNeeded(_ list: [Movie]) -> [Movie] {
        guard let order = sortOrder else { return list }
        return list.sorted(by: order)
    }
}
