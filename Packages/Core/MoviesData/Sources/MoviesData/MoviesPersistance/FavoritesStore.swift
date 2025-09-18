//
//  FavoritesStore.swift
//  MoviesData
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain
import AppLog

@MainActor
@Observable
public final class FavoritesStore {
    /// Repository for favorites
    @ObservationIgnored private let repository: FavoritesRepositoryProtocol
    /// Reactive set of favorite movie IDs
    public var favoriteMovieIds: Set<Int> = []
    /// Cancellables for managing subscriptions
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    /// Initialize with Combine-based loading
    public init(favoritesLocalDataSource: FavoritesLocalDataSourceProtocol = FavoritesLocalDataSource()) {
        self.repository = FavoritesRepository(localDataSource: favoritesLocalDataSource)
        loadFavorites()
    }

    /// Load favorites from storage using Combine
    private func loadFavorites() {
        repository.getFavoriteMovieIds()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    AppLog.persistence.error("Failed to load favorites: \(String(describing: error))")
                }
            }, receiveValue: { [weak self] favorites in
                self?.favoriteMovieIds = favorites
            })
            .store(in: &cancellables)
    }

    /// Remove favorite by id
    private func removeFavorite(for movieId: Int) {
        guard favoriteMovieIds.contains(movieId) else { return }
        favoriteMovieIds.remove(movieId)
        repository.removeFromFavorites(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure = completion { self.favoriteMovieIds.insert(movieId) }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    /// Check if movie is favorited
    private func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        repository.isMovieFavorited(movieId: movieId)
    }
}

// MARK: - Domain Favorites Protocol Conformance
extension FavoritesStore: FavoritesStoreProtocol {
    public func isFavorite(movieId: Int) -> Bool { favoriteMovieIds.contains(movieId) }
    public func removeFromFavorites(movieId: Int) { removeFavorite(for: movieId) }
    public func addToFavorites(movie: Movie) {
        repository.addToFavorites(movie: movie)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    AppLog.persistence.error("Failed to add favorite snapshot: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.favoriteMovieIds.insert(movie.id)
            })
            .store(in: &cancellables)
    }

    public func addToFavorites(details: MovieDetails) {
        repository.addToFavorites(details: details)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    AppLog.persistence.error("Failed to add favorite snapshot: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.favoriteMovieIds.insert(details.id)
            })
            .store(in: &cancellables)
    }

    public func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) async throws -> [Movie] {
        try await withCheckedThrowingContinuation { continuation in
            repository.getFavorites(page: page, pageSize: pageSize, sortOrder: sortOrder)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion { continuation.resume(throwing: error) }
                }, receiveValue: { movies in
                    continuation.resume(returning: movies)
                })
                .store(in: &cancellables)
        }
    }

    public func getFavoriteDetails(movieId: Int) async throws -> MovieDetails? {
        try await withCheckedThrowingContinuation { continuation in
            repository.getFavoriteDetails(movieId: movieId)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion { continuation.resume(throwing: error) }
                }, receiveValue: { details in
                    continuation.resume(returning: details)
                })
                .store(in: &cancellables)
        }
    }

    /// Toggle favorite status for a movie in a collection
    /// - Parameters:
    ///   - movieId: The ID of the movie to toggle
    ///   - items: Array of movies to find the movie data
    /// - Returns: The new favorite status (true = now favorited, false = now unfavorited)
    public func toggleFavorite(movieId: Int, in items: [Movie]) -> Bool {
        if isFavorite(movieId: movieId) {
            // Currently favorited, so remove it
            removeFromFavorites(movieId: movieId)
            return false  // Now unfavorited
        } else if let movie = items.first(where: { $0.id == movieId }) {
            // Not favorited, so add it
            addToFavorites(movie: movie)
            return true   // Now favorited
        }
        // Movie not found in items, return current status
        return isFavorite(movieId: movieId)
    }

    /// Toggle favorite status for movie details
    /// - Parameters:
    ///   - movieId: The ID of the movie to toggle
    ///   - movieDetails: The movie details data
    /// - Returns: The new favorite status
    public func toggleFavorite(movieId: Int, movieDetails: MovieDetails?) -> Bool {
        if isFavorite(movieId: movieId) {
            // Currently favorited, so remove it
            removeFromFavorites(movieId: movieId)
            return false  // Now unfavorited
        } else if let details = movieDetails {
            // Not favorited, so add it
            addToFavorites(details: details)
            return true   // Now favorited
        }
        // No details provided, return current status
        return isFavorite(movieId: movieId)
    }
}
