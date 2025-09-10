import XCTest
@testable import MoviesSearch

final class SearchViewTests: XCTestCase {
    func testSearchViewInitialization() {
        // Given
        let searchView = SearchView()

        // Then - View should initialize without crashing
        XCTAssertNotNil(searchView)
    }
}
