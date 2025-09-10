import XCTest
@testable import MoviesDetails

final class MovieDetailViewTests: XCTestCase {
    func testMovieDetailViewInitialization() {
        // Given
        let movieDetailView = MovieDetailView()

        // Then - View should initialize without crashing
        XCTAssertNotNil(movieDetailView)
    }
}
