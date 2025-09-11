//
//  HomeViewTests.swift
//  MoviesHomeTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
@testable import MoviesHome
@testable import MoviesDomain
@testable import MoviesPersistence

private final class RepoMock: MovieRepositoryProtocol {
    let fetchMoviesPageHandler: @Sendable (MovieType, Int) -> MoviePage = { type, page in
        let items = (0..<10).map { Movie(id: $0 + (page-1)*10, title: "M\($0)", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: Double($0), voteCount: 0) }
        return MoviePage(items: items, page: page, totalPages: 3)
    }

    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        Just(fetchMoviesPageHandler(type, page)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> { fatalError() }
}

@MainActor
final class HomeViewTests: XCTestCase {
    func testLoadResetReplacesItemsAndSetsPagination() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = HomeViewModel(repository: repo, favoritesStore: store)
        vm.category = .nowPlaying
        vm.load(reset: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.items.count, 10)
    }

    func testLoadNextThresholdTriggersPagination() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = HomeViewModel(repository: repo, favoritesStore: store)
        vm.category = .nowPlaying
        vm.load(reset: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        let last = vm.items.suffix(5).first
        vm.loadNextIfNeeded(currentItem: last)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertGreaterThan(vm.items.count, 10)
    }

    func testSetSortOrderAppliesSorting() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = HomeViewModel(repository: repo, favoritesStore: store)
        vm.category = .nowPlaying
        vm.load(reset: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        vm.setSortOrder(.ratingDescending)
        let sorted = vm.items.map { $0.voteAverage }
        XCTAssertEqual(sorted, sorted.sorted(by: >))
    }

    func testPaginationStopsAtLastPage() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = HomeViewModel(repository: repo, favoritesStore: store)
        vm.category = .nowPlaying
        // Load all 3 pages
        vm.load(reset: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        var last = vm.items.suffix(5).first
        vm.loadNextIfNeeded(currentItem: last)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        last = vm.items.suffix(5).first
        vm.loadNextIfNeeded(currentItem: last)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        let countAtMax = vm.items.count
        // Attempt beyond last page should not change count
        last = vm.items.suffix(3).first
        vm.loadNextIfNeeded(currentItem: last)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.items.count, countAtMax)
    }
}
