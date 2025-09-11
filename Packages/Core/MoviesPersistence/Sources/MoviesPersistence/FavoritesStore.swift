//
//  FavoritesStore.swift
//  MoviesPersistence
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain

@MainActor
@Observable
public final class FavoritesStore {
    /// Storage for persisting favorites data
    private let storage: FavoritesStorageProtocol
    /// Reactive set of favorite movie IDs
    public var favoriteMovieIds: Set<Int> = []
    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// Initialize with Combine-based loading
    public init(storage: FavoritesStorageProtocol = FavoritesStorage()) {
        self.storage = storage
        loadFavorites()
    }

    /// Load favorites from storage using Combine
    private func loadFavorites() {
        storage.getFavoriteMovieIds()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    #if DEBUG
                    print("Failed to load favorites: \(error)")
                    #endif
                }
            }, receiveValue: { [weak self] favorites in
                self?.favoriteMovieIds = favorites
            })
            .store(in: &cancellables)
    }

    /// Toggle favorite status for a movie
    public func toggleFavorite(movieId: Int) {
        if favoriteMovieIds.contains(movieId) {
            // Optimistic UI update
            favoriteMovieIds.remove(movieId)

            // Perform storage operation
            storage.removeFromFavorites(movieId: movieId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("Failed to remove favorite: \(error)")
                        #endif
                        // Revert optimistic update
                        self.favoriteMovieIds.insert(movieId)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        } else {
            // Optimistic UI update
            favoriteMovieIds.insert(movieId)

            // Perform storage operation
            storage.addToFavorites(movieId: movieId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("Failed to add favorite: \(error)")
                        #endif
                        // Revert optimistic update
                        self.favoriteMovieIds.remove(movieId)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }

    /// Check if movie is favorited
    public func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        storage.isFavorite(movieId: movieId)
    }

    /// Get current favorite movie IDs
    public func getFavoriteMovieIds() -> Set<Int> {
        favoriteMovieIds
    }
}
