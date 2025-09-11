//
//  FavoritesViewTests.swift
//  MoviesFavoritesTests
//
//  Created by User on 9/10/25.
//

import XCTest
@testable import MoviesFavorites
import MoviesDomain
import MoviesPersistence
import Combine

private final class RepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> { fatalError() }
}

@MainActor
final class FavoritesViewTests: XCTestCase {
    func testFavoritesViewInitialization() {
        // Given
        let favoritesView = FavoritesView(repository: RepoMock(), favoriteStore: FavoritesStore())

        // Then - View should initialize without crashing
        XCTAssertNotNil(favoritesView)
    }
}
