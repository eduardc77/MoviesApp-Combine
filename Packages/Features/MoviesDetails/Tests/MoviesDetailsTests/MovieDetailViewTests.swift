//
//  MovieDetailViewTests.swift
//  MoviesDetailsTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
@testable import MoviesDetails
@testable import MoviesDomain
@testable import MoviesPersistence

private final class InMemoryFavoritesStorage: FavoritesStorageProtocol {
    private var ids = Set<Int>()

    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Just(ids).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        ids.insert(movieId)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        ids.remove(movieId)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Just(ids.contains(movieId)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class RepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        let details = MovieDetails(id: id, title: "T", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 5, voteCount: 1, runtime: nil, genres: [], tagline: nil)
        return Just(details).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class FailingRepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        Fail(outputType: MovieDetails.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }
}

@MainActor
final class MovieDetailViewTests: XCTestCase {
    func testFetchLifecycleAndToggleFavorite() {
        let repo = RepoMock()
        let store = FavoritesStore(storage: InMemoryFavoritesStorage())
        let vm = MovieDetailViewModel(repository: repo, favoritesStore: store, movieId: 7)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.movie?.id, 7)
        vm.toggleFavorite()
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        XCTAssertTrue(store.getFavoriteMovieIds().contains(7))
    }

    func testFetchSetsErrorOnFailure() {
        let repo = FailingRepoMock()
        let store = FavoritesStore()
        let vm = MovieDetailViewModel(repository: repo, favoritesStore: store, movieId: 1)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertNotNil(vm.error)
        XCTAssertNil(vm.movie)
    }
}
