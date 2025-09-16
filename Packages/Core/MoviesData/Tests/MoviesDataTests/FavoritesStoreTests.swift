//
//  FavoritesStoreTests.swift
//  MoviesDataTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
@testable import MoviesData

private final class LocalDataSourceMock: @unchecked Sendable, FavoritesLocalDataSourceProtocol {
    var ids: Set<Int> = []
    var shouldFail = false

    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Just(ids).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        if shouldFail { return Fail(error: NSError(domain: "x", code: -1)).eraseToAnyPublisher() }
        ids.insert(movieId)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        if shouldFail { return Fail(error: NSError(domain: "x", code: -1)).eraseToAnyPublisher() }
        ids.remove(movieId)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Just(ids.contains(movieId)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

@MainActor
final class FavoritesStoreTests: XCTestCase {
    func testInitialLoadPopulatesIds() {
        let mock = LocalDataSourceMock()
        mock.ids = [1,2]
        let store = FavoritesStore(favoritesLocalDataSource: mock)
        let exp = expectation(description: "loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(store.favoriteMovieIds, [1,2])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testToggleFavoriteAddsOptimisticallyAndRollsBackOnFailure() {
        let mock = LocalDataSourceMock()
        let store = FavoritesStore(favoritesLocalDataSource: mock)
        // Ensure initial load completed before mutating
        let exp = expectation(description: "loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        store.toggleFavorite(movieId: 10)
        XCTAssertTrue(store.favoriteMovieIds.contains(10))
        mock.shouldFail = true
        store.toggleFavorite(movieId: 10) // attempt remove, will fail and roll back
        let revert = expectation(description: "reverted")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertTrue(store.favoriteMovieIds.contains(10))
            revert.fulfill()
        }
        wait(for: [revert], timeout: 1.0)
    }
}


