//
//  FavoritesRepositoryProtocol.swift
//  MoviesDomain
//
//  Created by User on 9/14/25.
//

import Combine

/// Protocol for managing favorite movies
public protocol FavoritesRepositoryProtocol {
    /// Gets all favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Checks if a movie is favorited
    func isMovieFavorited(movieId: Int) -> AnyPublisher<Bool, Error>

    /// Removes favorite by id
    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Adds a snapshot of a Movie to favorites
    func addToFavorites(movie: Movie) -> AnyPublisher<Void, Error>

    /// Adds a snapshot of MovieDetails to favorites
    func addToFavorites(details: MovieDetails) -> AnyPublisher<Void, Error>

    /// Fetch a page of favorited movies from local storage
    func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Error>

    /// Fetch locally stored favorite details snapshot if available
    func getFavoriteDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error>
}
