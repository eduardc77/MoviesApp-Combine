//
//  MovieDetailViewTests.swift
//  MoviesDetailsTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
import SharedModels
import MoviesDomain
@testable import MoviesDetails
@testable import MoviesDomain
@testable import MoviesData

private final class InMemoryFavoritesLocalDataSource: @unchecked Sendable, FavoritesLocalDataSourceProtocol {
    private var ids = Set<Int>()

    func getFavoriteMovieIds() throws -> Set<Int> {
        return ids
    }

    func addToFavorites(movie: Movie) throws {
        ids.insert(movie.id)
    }

    func addToFavorites(details: MovieDetails) throws {
        ids.insert(details.id)
    }

    func removeFromFavorites(movieId: Int) throws {
        ids.remove(movieId)
    }

    func isFavorite(movieId: Int) -> Bool {
        return ids.contains(movieId)
    }

    func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) throws -> [Movie] {
        let sorted = Array(ids).sorted()
        let start = max(page - 1, 0) * pageSize
        let end = min(start + pageSize, sorted.count)
        let slice = (start < end) ? Array(sorted[start..<end]) : []
        return slice.map { id in Movie(id: id, title: "t\(id)", overview: "o", posterPath: nil, backdropPath: nil, releaseDate: "2023-01-01", voteAverage: 0, voteCount: 0, genres: [], popularity: 0) }
    }

    func getFavoriteDetails(movieId: Int) -> MovieDetails? {
        if ids.contains(movieId) {
            return MovieDetails(id: movieId, title: "t\(movieId)", overview: "o", posterPath: nil, backdropPath: nil, releaseDate: "2023-01-01", voteAverage: 0, voteCount: 0, runtime: 100, genres: [], tagline: nil)
        }
        return nil
    }

    // Synchronous methods for incremental updates
    func getFavoriteMovieSync(movieId: Int) -> Movie? {
        if ids.contains(movieId) {
            return Movie(id: movieId, title: "t\(movieId)", overview: "o", posterPath: nil, backdropPath: nil, releaseDate: "2023-01-01", voteAverage: 0, voteCount: 0, genres: [], popularity: 0)
        }
        return nil
    }

    func getFavoriteDetailsSync(movieId: Int) -> MovieDetails? {
        if ids.contains(movieId) {
            return MovieDetails(id: movieId, title: "t\(movieId)", overview: "o", posterPath: nil, backdropPath: nil, releaseDate: "2023-01-01", voteAverage: 0, voteCount: 0, runtime: 100, genres: [], tagline: nil)
        }
        return nil
    }

    func isFavoriteSync(movieId: Int) -> Bool {
        return ids.contains(movieId)
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
