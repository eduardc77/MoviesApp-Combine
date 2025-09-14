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

private final class InMemoryFavoritesLocalDataSource: FavoritesLocalDataSourceProtocol {
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
    func fetchMovies(type: MovieType, page: Int, sortBy: MovieSortOrder?) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        let details = MovieDetails(id: id, title: "Movie \(id)", overview: "Detailed overview for movie \(id)", posterPath: "/poster\(id).jpg", backdropPath: "/backdrop\(id).jpg", releaseDate: "2023-01-01", voteAverage: 7.5, voteCount: 100, runtime: 120, genres: [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")], tagline: "An epic adventure")
        return Just(details).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class FailingRepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> {
        Fail(outputType: [Movie].self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }

    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        Fail(outputType: MoviePage.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }

    func fetchMovies(type: MovieType, page: Int, sortBy: MovieSortOrder?) -> AnyPublisher<MoviePage, Error> {
        Fail(outputType: MoviePage.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }

    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        Fail(outputType: [Movie].self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }

    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        Fail(outputType: MoviePage.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        Fail(outputType: MovieDetails.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
    }
}

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    func testFetchLifecycleAndToggleFavorite() {
        let repo = RepoMock()
        let store = FavoritesStore(favoritesLocalDataSource: InMemoryFavoritesLocalDataSource())
        let vm = MovieDetailViewModel(repository: repo, favoritesStore: store, movieId: 7)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.movie?.id, 7)
        vm.toggleFavorite()
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        XCTAssertTrue(store.favoriteMovieIds.contains(7))
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
