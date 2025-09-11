//
//  FavoritesStorage.swift
//  MoviesPersistence
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain

/// Clean protocol for favorites storage using Combine
public protocol FavoritesStorageProtocol {
    /// Get current favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Add movie to favorites
    func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Remove movie from favorites
    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Check if movie is favorited
    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

/// Thread-safe favorites storage using Combine
/// Uses UserDefaults with proper synchronization for read-modify-write operations
public final class FavoritesStorage: FavoritesStorageProtocol {
    private let favoritesKey = "favorite_movies"
    private let userDefaults: UserDefaults
    private let queue = DispatchQueue(label: "com.movies.favorites", qos: .userInitiated)

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Get favorites using Combine (reads are safe without queue)
    public func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Deferred {
            Future { promise in
                // UserDefaults reads are thread-safe
                let ids = self.userDefaults.array(forKey: self.favoritesKey) as? [Int] ?? []
                let favorites = Set(ids)
                promise(.success(favorites))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Add to favorites using Combine (atomic write operation)
    public func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [userDefaults = self.userDefaults, favoritesKey = self.favoritesKey] promise in
                // Perform mutation on the storage queue via subscription scheduling
                let ids = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
                var favorites = Set(ids)

                if favorites.insert(movieId).inserted {
                    userDefaults.set(Array(favorites), forKey: favoritesKey)
                }
                promise(.success(()))
            }
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }

    /// Remove from favorites using Combine (atomic write operation)
    public func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [userDefaults = self.userDefaults, favoritesKey = self.favoritesKey] promise in
                // Perform mutation on the storage queue via subscription scheduling
                let ids = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
                var favorites = Set(ids)

                if favorites.remove(movieId) != nil {
                    userDefaults.set(Array(favorites), forKey: favoritesKey)
                }
                promise(.success(()))
            }
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }

    /// Check favorite status using Combine (read-only, safe)
    public func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { promise in
                // UserDefaults reads are thread-safe
                let ids = self.userDefaults.array(forKey: self.favoritesKey) as? [Int] ?? []
                let favorites = Set(ids)
                let isFav = favorites.contains(movieId)
                promise(.success(isFav))
            }
        }
        .eraseToAnyPublisher()
    }
}
