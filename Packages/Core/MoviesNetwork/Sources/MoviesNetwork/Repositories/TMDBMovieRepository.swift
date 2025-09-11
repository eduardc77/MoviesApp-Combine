//
//  TMDBMovieRepository.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Combine
import MoviesDomain
import MoviesUtilities

/// Concrete implementation of MovieRepository using TMDB API
public final class TMDBMovieRepository: MovieRepositoryProtocol {
    private let remoteDataSource: TMDBRemoteDataSourceProtocol

    public init(remoteDataSource: TMDBRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> {
        return remoteDataSource.fetchMovies(type: type)
    }

    public func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        return remoteDataSource.fetchMovies(type: type, page: page)
    }

    public func searchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        return remoteDataSource.searchMovies(query: query)
    }

    public func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        return remoteDataSource.searchMovies(query: query, page: page)
    }

    public func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        return remoteDataSource.fetchMovieDetails(id: id)
    }
}

// MARK: - Repository Creation
public extension TMDBMovieRepository {
    /// Creates a TMDBMovieRepository with static configuration
    static func development() -> TMDBMovieRepository {
        let networkingClient = TMDBNetworkingClient(networkingConfig: TMDBNetworkingConfig.config)
        let remoteDataSource = TMDBRemoteDataSource(networkingClient: networkingClient)
        return TMDBMovieRepository(remoteDataSource: remoteDataSource)
    }
}
