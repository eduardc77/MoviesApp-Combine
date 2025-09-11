//
//  FavoritesViewTests.swift
//  MoviesFavoritesTests
//
//  Created by User on 9/10/25.
//

import XCTest
@testable import MoviesFavorites

final class FavoritesViewTests: XCTestCase {
    func testFavoritesViewInitialization() {
        // Given
        let favoritesView = FavoritesView()

        // Then - View should initialize without crashing
        XCTAssertNotNil(favoritesView)
    }
}
