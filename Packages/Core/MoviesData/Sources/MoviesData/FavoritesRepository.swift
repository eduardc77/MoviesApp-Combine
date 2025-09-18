//
//  FavoritesRepository.swift
//  MoviesData
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import MoviesDomain

/// Adapter that exposes a Combine repository API backed by a local storage
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let localDataSource: FavoritesLocalDataSourceProtocol

    public init(localDataSource: FavoritesLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    public func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        localDataSource.getFavoriteMovieIds()
    }

    public func isMovieFavorited(movieId: Int) -> AnyPublisher<Bool, Error> {
        localDataSource.isFavorite(movieId: movieId)
    }

    public func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        localDataSource.removeFromFavorites(movieId: movieId)
    }

    public func addToFavorites(movie: Movie) -> AnyPublisher<Void, Error> {
        localDataSource.addToFavorites(movie: movie)
    }

    public func addToFavorites(details: MovieDetails) -> AnyPublisher<Void, Error> {
        localDataSource.addToFavorites(details: details)
    }

    public func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Error> {
        localDataSource.getFavorites(page: page, pageSize: pageSize, sortOrder: sortOrder)
    }

    public func getFavoriteDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error> {
        localDataSource.getFavoriteDetails(movieId: movieId)
    }
}
