//
//  FavoritesStorageTests.swift
//  MoviesPersistenceTests
//
//  Created by User on 9/10/25.
//

import XCTest
import Combine
@testable import MoviesPersistence

final class FavoritesStorageTests: XCTestCase {
    private var sut: FavoritesStorage!
    private var mockUserDefaults: UserDefaults!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        let suite = "test_suite_\(UUID().uuidString)"
        mockUserDefaults = UserDefaults(suiteName: suite)!
        sut = FavoritesStorage(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        // Remove domain using known suite identifier
        if let suite = mockUserDefaults?.persistentDomain(forName: "test_suite") {
            _ = suite // noop, ensure access
            mockUserDefaults.removePersistentDomain(forName: "test_suite")
        }
        mockUserDefaults = nil
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testGetFavoriteMovieIdsEmpty() {
        let exp = expectation(description: "empty")
        sut.getFavoriteMovieIds()
            .sink(receiveCompletion: { _ in }, receiveValue: { ids in
                XCTAssertTrue(ids.isEmpty)
                exp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 1)
    }

    func testAddAndRemoveFavorites() {
        let add1 = expectation(description: "add1")
        sut.addToFavorites(movieId: 1)
            .sink(receiveCompletion: { _ in add1.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [add1], timeout: 1)

        let add2 = expectation(description: "add2")
        sut.addToFavorites(movieId: 2)
            .sink(receiveCompletion: { _ in add2.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [add2], timeout: 1)

        let isFav = expectation(description: "isFav")
        sut.isFavorite(movieId: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                XCTAssertTrue(value)
                isFav.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [isFav], timeout: 1)

        let remove = expectation(description: "remove")
        sut.removeFromFavorites(movieId: 1)
            .sink(receiveCompletion: { _ in remove.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [remove], timeout: 1)
    }

    func testDuplicateAddToFavoritesKeepsSingleEntry() {
        let add1 = expectation(description: "add1")
        sut.addToFavorites(movieId: 1)
            .sink(receiveCompletion: { _ in add1.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [add1], timeout: 1)

        let add2 = expectation(description: "add2")
        sut.addToFavorites(movieId: 1)
            .sink(receiveCompletion: { _ in add2.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [add2], timeout: 1)

        let idsExp = expectation(description: "ids")
        sut.getFavoriteMovieIds()
            .sink(receiveCompletion: { _ in }, receiveValue: { ids in
                XCTAssertEqual(ids.count, 1)
                XCTAssertTrue(ids.contains(1))
                idsExp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [idsExp], timeout: 1)
    }

    func testConcurrentOps_noDeadlock() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        for i in 0..<15 {
            group.enter()
            queue.async {
                _ = self.sut.addToFavorites(movieId: i).sink(receiveCompletion: { _ in group.leave() }, receiveValue: { _ in })
            }
        }
        let result = group.wait(timeout: .now() + 3)
        XCTAssertEqual(result, .success)
    }
}
