//
//  FavoritesRepositoryProtocol.swift
//  MoviesDomain
//
//  Created by User on 9/14/25.
//

import Combine

@MainActor
/// Protocol for managing favorite movies
public protocol FavoritesRepositoryProtocol {
    /// Gets all favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Checks if a movie is favorited
    func isMovieFavorited(movieId: Int) -> AnyPublisher<Bool, Error>

    /// Toggles favorite status for a movie
    func toggleFavorite(movieId: Int) -> AnyPublisher<Void, Error>
}
