//
//  FavoritesViewModelTests.swift
//  MoviesFavoritesTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
import SharedModels
@testable import MoviesFavorites
@testable import MoviesDomain
@testable import MoviesData

private class InMemoryFavoritesLocalDataSource: @unchecked Sendable, FavoritesLocalDataSourceProtocol {
    private var ids = Set<Int>()
    private let queue = DispatchQueue(label: "com.movies.favorites.test")

    nonisolated func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Future { promise in
            self.queue.async {
                promise(.success(self.ids))
            }
        }.eraseToAnyPublisher()
    }

    nonisolated func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.queue.async {
                self.ids.insert(movieId)
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    nonisolated func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.queue.async {
                self.ids.remove(movieId)
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    nonisolated func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.queue.async {
                promise(.success(self.ids.contains(movieId)))
            }
        }.eraseToAnyPublisher()
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

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func testReloadReflectsFavoritesAfterToggle() {
        let repo = RepoMock()
        let store = FavoritesStore(favoritesLocalDataSource: InMemoryFavoritesLocalDataSource())
        let vm = FavoritesViewModel(repository: repo, favoritesStore: store)

        // Initially empty
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertTrue(vm.items.isEmpty)

        // Toggle favorite and reload
        store.toggleFavorite(movieId: 42)
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.items.map { $0.id }, [42])

        // Toggle off and reload
        store.toggleFavorite(movieId: 42)
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertTrue(vm.items.isEmpty)
    }

    func testFavoritesStoreIsAccessibleForObservation() {
        let repo = RepoMock()
        let store = FavoritesStore(favoritesLocalDataSource: InMemoryFavoritesLocalDataSource())
        let vm = FavoritesViewModel(repository: repo, favoritesStore: store)

        // Verify ViewModel exposes store for View observation
        XCTAssertNotNil(vm.favoritesStore)
        XCTAssertTrue(vm.favoritesStore.favoriteMovieIds.isEmpty)
    }
}
