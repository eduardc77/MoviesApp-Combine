//
//  MovieRemoteDataSource.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Combine
import SharedModels

/// Protocol defining TMDB remote data source operations
/// Follows repository pattern with remote data source abstraction
public protocol MovieRemoteDataSourceProtocol: Sendable {
    func fetchMovies(type: MovieType) -> AnyPublisher<MoviesResponseDTO, Error>
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviesResponseDTO, Error>
    func fetchMovies(type: MovieType, page: Int, sortBy: String?) -> AnyPublisher<MoviesResponseDTO, Error>
    func searchMovies(query: String) -> AnyPublisher<MoviesResponseDTO, Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviesResponseDTO, Error>
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetailsDTO, Error>
}

/// Remote data source implementation for TMDB API
/// Uses the networking client internally for HTTP operations
public final class MovieRemoteDataSource: MovieRemoteDataSourceProtocol {
    private let networkingClient: TMDBNetworkingClientProtocol

    public init(networkingClient: TMDBNetworkingClientProtocol) {
        self.networkingClient = networkingClient
    }

    public func fetchMovies(type: MovieType) -> AnyPublisher<MoviesResponseDTO, Error> {
        let endpoint = MoviesEndpoints.movies(type: type, page: 1)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviesResponseDTO, Error> {
        let endpoint = MoviesEndpoints.movies(type: type, page: page)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int, sortBy: String?) -> AnyPublisher<MoviesResponseDTO, Error> {
        let endpoint = MoviesEndpoints.discoverMovies(type: type, page: page, sortBy: sortBy)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String) -> AnyPublisher<MoviesResponseDTO, Error> {
        let endpoint = MoviesEndpoints.searchMovies(query: query, page: 1)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String, page: Int) -> AnyPublisher<MoviesResponseDTO, Error> {
        let endpoint = MoviesEndpoints.searchMovies(query: query, page: page)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }

    public func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetailsDTO, Error> {
        let endpoint = MoviesEndpoints.movieDetails(id: id)
        return networkingClient.request(endpoint)
            .eraseToAnyPublisher()
    }
}
