//
//  MovieRepository.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Combine
import MoviesDomain
import MoviesUtilities
import Foundation

/// Concrete implementation of MovieRepository using TMDB API
public final class MovieRepository: MovieRepositoryProtocol {
    private let remoteDataSource: MovieRemoteDataSourceProtocol

    public init(remoteDataSource: MovieRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> {
        return remoteDataSource.fetchMovies(type: type)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        return remoteDataSource.fetchMovies(type: type, page: page)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchMovies(type: MovieType, page: Int, sortBy: MovieSortOrder?) -> AnyPublisher<MoviePage, Error> {
        return remoteDataSource.fetchMovies(type: type, page: page, sortBy: sortBy?.tmdbSortValue)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        return remoteDataSource.searchMovies(query: query)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }

    public func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        return remoteDataSource.searchMovies(query: query, page: page)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        return remoteDataSource.fetchMovieDetails(id: id)
            .mapError { MovieRepository.mapToDomainError($0) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Repository Creation
public extension MovieRepository {
    /// Creates a TMDBMovieRepository with static configuration
    static func development() -> MovieRepository {
        let networkingClient = TMDBNetworkingClient(networkingConfig: TMDBNetworkingConfig.config)
        let remoteDataSource = MovieRemoteDataSource(networkingClient: networkingClient)
        return MovieRepository(remoteDataSource: remoteDataSource)
    }
}

// MARK: - Error Mapping
private extension MovieRepository {
    static func mapToDomainError(_ error: Error) -> Error {
        // Map infra/network errors to DomainError while preserving public failure type as Error
        if let netErr = error as? TMDBNetworkingError {
            switch netErr {
            case .invalidURL:
                return DomainError.network(underlying: netErr)
            case .networkError(let underlying):
                return DomainError.network(underlying: underlying)
            case .decodingError(let underlying):
                return DomainError.decoding(underlying: underlying)
            case .httpError(let code):
                if code == 401 { return DomainError.unauthorized }
                if code == 404 { return DomainError.notFound }
                if code == 429 { return DomainError.rateLimited }
                return DomainError.httpStatus(code: code)
            }
        }
        return DomainError.unknown(underlying: error)
    }
}
