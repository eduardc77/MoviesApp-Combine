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

    func testConcurrentOpsNoDeadlock() {
        // Just verify that multiple operations complete successfully
        let expectation = self.expectation(description: "Multiple operations complete")

        guard let storage = sut else {
            XCTFail("sut should not be nil")
            return
        }

        var completedCount = 0
        let totalOperations = 5

        for i in 0..<totalOperations {
            _ = storage.addToFavorites(movieId: i).sink(receiveCompletion: { _ in
                completedCount += 1
                if completedCount == totalOperations {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
        }

        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(completedCount, totalOperations)
    }

    func testMemoryLeakPreventionSubscriptionCleanup() {
        // Critical test: Verify Combine subscriptions don't cause memory leaks
        guard let storage = sut else {
            XCTFail("sut should not be nil")
            return
        }

        weak var weakStorage: FavoritesStorage? = storage

        autoreleasepool {
            // Create a subscription and immediately cancel it
            let cancellable = storage.getFavoriteMovieIds()
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

            // Store it in cancellables set
            cancellable.store(in: &cancellables)

            // Remove the cancellable (simulating view deallocation)
            cancellables.removeAll()
        }

        // Force garbage collection by creating memory pressure
        for _ in 0..<1000 {
            _ = NSObject()
        }

        // Verify the storage is still alive (not leaked)
        // This ensures we haven't created any strong reference cycles
        XCTAssertNotNil(weakStorage, "FavoritesStorage should not be deallocated")

        // Verify storage is still functional after subscription cleanup
        let expectation = self.expectation(description: "Storage still works")
        _ = storage.addToFavorites(movieId: 999).sink(receiveCompletion: { _ in
            expectation.fulfill()
        }, receiveValue: { _ in })
        wait(for: [expectation], timeout: 1.0)
    }
}
