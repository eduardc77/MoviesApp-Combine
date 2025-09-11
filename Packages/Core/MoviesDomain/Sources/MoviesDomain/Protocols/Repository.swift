//
//  Repository.swift
//  MoviesDomain
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine

public struct MoviePage: Sendable {
    public let items: [Movie]
    public let page: Int
    public let totalPages: Int
    public init(items: [Movie], page: Int, totalPages: Int) {
        self.items = items
        self.page = page
        self.totalPages = totalPages
    }
}

/// Protocol defining the core movie repository operations
public protocol MovieRepositoryProtocol: Sendable {
    /// Fetches movies of a specific type from the data source
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error>
    /// Fetches movies of a specific type for a page
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error>

    /// Searches for movies based on a query string
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error>
    /// Searches for movies based on a query string and page
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error>

    /// Fetches detailed information for a specific movie
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error>
}

/// Protocol for managing favorite movies
public protocol FavoritesRepositoryProtocol: Sendable {
    /// Gets all favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Checks if a movie is favorited
    func isMovieFavorited(movieId: Int) -> AnyPublisher<Bool, Error>

    /// Toggles favorite status for a movie
    func toggleFavorite(movieId: Int) -> AnyPublisher<Void, Error>
}
