//
//  FavoritesStorage.swift
//  MoviesPersistence
//
//  Created by User on 9/10/25.
//

import Foundation
import MoviesModels

public protocol FavoritesStorageProtocol {
    func getFavoriteMovieIds() -> Set<Int>
    func addToFavorites(movieId: Int)
    func removeFromFavorites(movieId: Int)
    func isFavorite(movieId: Int) -> Bool
}

public final class FavoritesStorage: FavoritesStorageProtocol {
    private let favoritesKey = "favorite_movies"
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func getFavoriteMovieIds() -> Set<Int> {
        let ids = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        return Set(ids)
    }

    public func addToFavorites(movieId: Int) {
        var favorites = getFavoriteMovieIds()
        favorites.insert(movieId)
        saveFavorites(favorites)
    }

    public func removeFromFavorites(movieId: Int) {
        var favorites = getFavoriteMovieIds()
        favorites.remove(movieId)
        saveFavorites(favorites)
    }

    public func isFavorite(movieId: Int) -> Bool {
        return getFavoriteMovieIds().contains(movieId)
    }

    private func saveFavorites(_ favorites: Set<Int>) {
        let ids = Array(favorites)
        userDefaults.set(ids, forKey: favoritesKey)
    }
}
