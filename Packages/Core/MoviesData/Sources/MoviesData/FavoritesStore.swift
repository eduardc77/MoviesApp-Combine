//
//  FavoritesStore.swift
//  MoviesData
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain
import MoviesLogging

@MainActor
@Observable
public final class FavoritesStore {
    /// Repository for favorites (local SwiftData now, remote later if needed)
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

    /// Toggle favorite status for a movie
    private func toggleFavorite(for movieId: Int) {
        if favoriteMovieIds.contains(movieId) {
            // Optimistic UI update
            favoriteMovieIds.remove(movieId)

            // Perform repository operation
            repository.toggleFavorite(movieId: movieId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        AppLog.persistence.error("Failed to remove favorite: \(String(describing: error))")
                        // Revert optimistic update
                        self.favoriteMovieIds.insert(movieId)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        } else {
            // Optimistic UI update
            favoriteMovieIds.insert(movieId)

            // Perform repository operation
            repository.toggleFavorite(movieId: movieId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        AppLog.persistence.error("Failed to add favorite: \(String(describing: error))")
                        // Revert optimistic update
                        self.favoriteMovieIds.remove(movieId)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }

    /// Check if movie is favorited
    private func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        repository.isMovieFavorited(movieId: movieId)
    }
}

// MARK: - Domain Favorites Protocol Conformance
extension FavoritesStore: FavoritesStoreProtocol {
    public func isFavorite(movieId: Int) -> Bool { favoriteMovieIds.contains(movieId) }
    public func toggleFavorite(movieId: Int) { toggleFavorite(for: movieId) }
}
