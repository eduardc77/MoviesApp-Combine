//
//  FavoritesStorageTests.swift
//  MoviesPersistenceTests
//
//  Created by User on 9/10/25.
//

import XCTest
@testable import MoviesPersistence

final class FavoritesStorageTests: XCTestCase {
    private var sut: FavoritesStorage!
    private var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test_suite")!
        sut = FavoritesStorage(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "test_suite")
        mockUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    func testGetFavoriteMovieIds_Empty() {
        // When
        let favoriteIds = sut.getFavoriteMovieIds()

        // Then
        XCTAssertTrue(favoriteIds.isEmpty)
    }

    func testAddToFavorites() {
        // When
        sut.addToFavorites(movieId: 1)
        sut.addToFavorites(movieId: 2)

        // Then
        let favoriteIds = sut.getFavoriteMovieIds()
        XCTAssertEqual(favoriteIds, [1, 2])
    }

    func testRemoveFromFavorites() {
        // Given
        sut.addToFavorites(movieId: 1)
        sut.addToFavorites(movieId: 2)

        // When
        sut.removeFromFavorites(movieId: 1)

        // Then
        let favoriteIds = sut.getFavoriteMovieIds()
        XCTAssertEqual(favoriteIds, [2])
    }

    func testIsFavorite_True() {
        // Given
        sut.addToFavorites(movieId: 123)

        // When
        let isFavorite = sut.isFavorite(movieId: 123)

        // Then
        XCTAssertTrue(isFavorite)
    }

    func testIsFavorite_False() {
        // When
        let isFavorite = sut.isFavorite(movieId: 999)

        // Then
        XCTAssertFalse(isFavorite)
    }

    func testDuplicateAddToFavorites() {
        // When
        sut.addToFavorites(movieId: 1)
        sut.addToFavorites(movieId: 1)

        // Then
        let favoriteIds = sut.getFavoriteMovieIds()
        XCTAssertEqual(favoriteIds.count, 1)
        XCTAssertTrue(favoriteIds.contains(1))
    }

    func testRemoveNonExistentFavorite() {
        // Given
        sut.addToFavorites(movieId: 1)

        // When
        sut.removeFromFavorites(movieId: 999)

        // Then
        let favoriteIds = sut.getFavoriteMovieIds()
        XCTAssertEqual(favoriteIds, [1])
    }
}
