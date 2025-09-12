//
//  TMDBRemoteDataSource.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Combine
import MoviesDomain

/// Protocol defining TMDB remote data source operations
/// Follows repository pattern with remote data source abstraction
public protocol TMDBRemoteDataSourceProtocol: Sendable {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error>
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error>
    func fetchMovies(type: MovieType, page: Int, sortBy: String?) -> AnyPublisher<MoviePage, Error>
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error>
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error>
}

/// Remote data source implementation for TMDB API
/// Uses the networking client internally for HTTP operations
public final class TMDBRemoteDataSource: TMDBRemoteDataSourceProtocol {
    private let networkingClient: TMDBNetworkingClientProtocol

    public init(networkingClient: TMDBNetworkingClientProtocol) {
        self.networkingClient = networkingClient
    }

    public func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> {
        let endpoint = MoviesEndpoints.movies(type: type, page: 1)
        return networkingClient.request(endpoint)
            .map { (response: MoviesResponseDTO) in DTOMapper.toDomain(response.results) }
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        let endpoint = MoviesEndpoints.movies(type: type, page: page)
        return networkingClient.request(endpoint)
            .map { (response: MoviesResponseDTO) in
                MoviePage(items: DTOMapper.toDomain(response.results), page: response.page, totalPages: response.totalPages)
            }
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int, sortBy: String?) -> AnyPublisher<MoviePage, Error> {
        let endpoint = MoviesEndpoints.discoverMovies(type: type, page: page, sortBy: sortBy)
        return networkingClient.request(endpoint)
            .map { (response: MoviesResponseDTO) in
                MoviePage(items: DTOMapper.toDomain(response.results), page: response.page, totalPages: response.totalPages)
            }
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        let endpoint = MoviesEndpoints.searchMovies(query: query, page: 1)
        return networkingClient.request(endpoint)
            .map { (response: MoviesResponseDTO) in DTOMapper.toDomain(response.results) }
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        let endpoint = MoviesEndpoints.searchMovies(query: query, page: page)
        return networkingClient.request(endpoint)
            .map { (response: MoviesResponseDTO) in
                MoviePage(items: DTOMapper.toDomain(response.results), page: response.page, totalPages: response.totalPages)
            }
            .eraseToAnyPublisher()
    }

    public func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        let endpoint = MoviesEndpoints.movieDetails(id: id)
        return networkingClient.request(endpoint)
            .map { (response: MovieDetailsDTO) in DTOMapper.toDomain(response) }
            .eraseToAnyPublisher()
    }
}
