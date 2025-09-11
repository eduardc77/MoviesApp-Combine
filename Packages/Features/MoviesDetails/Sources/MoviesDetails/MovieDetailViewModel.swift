//
//  MovieDetailViewModel.swift
//  MoviesDetails
//

import Foundation
import Combine
import MoviesDomain
import MoviesPersistence

@MainActor
public final class MovieDetailViewModel: ObservableObject {
    @Published public private(set) var movie: MovieDetails?
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?

    private let repository: MovieRepositoryProtocol
    private let favoritesStore: FavoritesStore
    private let movieId: Int
    private var cancellables = Set<AnyCancellable>()

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStore, movieId: Int) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.movieId = movieId
        fetch()
    }

    public func fetch() {
        isLoading = true
        error = nil
        repository.fetchMovieDetails(id: movieId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let err) = completion { self.error = err }
            }, receiveValue: { [weak self] details in
                self?.movie = details
            })
            .store(in: &cancellables)
    }

    public func toggleFavorite() {
        guard let id = movie?.id else { return }
        favoritesStore.toggleFavorite(movieId: id)
    }

    public func isFavorite() -> Bool {
        guard let id = movie?.id else { return false }
        return favoritesStore.getFavoriteMovieIds().contains(id)
    }
}
