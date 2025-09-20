//
//  MovieDetailViewModel.swift
//  MoviesDetails
//

import Foundation
import Combine
import MoviesDomain

@MainActor
@Observable
public final class MovieDetailViewModel {
    public private(set) var movie: MovieDetails?
    public private(set) var isLoading = false
    public private(set) var error: Error?

    @ObservationIgnored private let repository: MovieRepositoryProtocol
    @ObservationIgnored private let favoritesStore: FavoritesStoreProtocol
    @ObservationIgnored private let movieId: Int
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    public init(repository: MovieRepositoryProtocol, favoritesStore: FavoritesStoreProtocol, movieId: Int) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.movieId = movieId
        fetch()
        // Offline-first: try local details snapshot
        if let local = favoritesStore.getFavoriteDetails(movieId: movieId), self.movie == nil {
            self.movie = local
        }
    }

    // MARK: - View State
    public enum DetailViewState {
        case loading
        case error(Error)
        case content(MovieDetails)
    }

    public var state: DetailViewState {
        switch true {
        case error != nil:
            return .error(error!)
        case movie != nil:
            return .content(movie!)
        default:
            return .loading
        }
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
        _ = favoritesStore.toggleFavorite(movieId: movieId, movieDetails: movie)
    }

    public func isFavorite() -> Bool {
        return favoritesStore.isFavorite(movieId: movieId)
    }
}
