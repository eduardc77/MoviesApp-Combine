//
//  SearchViewTests.swift
//  MoviesSearchTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
@testable import MoviesSearch
@testable import MoviesDomain
@testable import MoviesPersistence

private final class RepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        let items = (0..<5).map { Movie(id: $0, title: "S\($0)", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 0, voteCount: 0) }
        return Just(MoviePage(items: items, page: page, totalPages: 2)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> { fatalError() }
}

@MainActor
final class SearchViewTests: XCTestCase {
    func testSearchPaginatesAndGuardsMinLength() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = SearchViewModel(repository: repo, favoritesStore: store)

        vm.search(reset: true) // query empty -> should no-op
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        XCTAssertTrue(vm.items.isEmpty)

        vm.query = "abc"
        vm.search(reset: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.items.count, 5)

        vm.loadNextIfNeeded(currentItem: vm.items.last)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertGreaterThan(vm.items.count, 5)
    }
}
