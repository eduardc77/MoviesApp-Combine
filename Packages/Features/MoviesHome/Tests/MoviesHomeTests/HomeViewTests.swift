//
//  HomeViewTests.swift
//  MoviesHomeTests
//
//  Created by User on 9/10/25.
//

import XCTest
@testable import MoviesHome

final class HomeViewTests: XCTestCase {
    func testHomeViewInitialization() {
        // Given
        let homeView = HomeView()

        // Then - View should initialize without crashing
        XCTAssertNotNil(homeView)
    }

    // Note: UI tests would typically be in UITests target
    // These are unit tests for any view models or business logic
    // that might be extracted from the view
}
