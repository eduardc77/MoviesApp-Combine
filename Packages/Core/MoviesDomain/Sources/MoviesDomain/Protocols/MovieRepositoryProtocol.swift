//
//  MovieRepositoryProtocol.swift
//  MoviesDomain
//
//  Created by User on 9/10/25.
//

import Combine

/// Protocol defining the core movie repository operations
public protocol MovieRepositoryProtocol: Sendable {
    /// Fetches movies of a specific type from the data source
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error>
    /// Fetches movies of a specific type for a page
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error>
    /// Fetches movies of a specific type for a page with server-side sorting
    func fetchMovies(type: MovieType, page: Int, sortBy: MovieSortOrder?) -> AnyPublisher<MoviePage, Error>

    /// Searches for movies based on a query string
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error>
    /// Searches for movies based on a query string and page
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error>

    /// Fetches detailed information for a specific movie
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error>
}
