import XCTest
@testable import MoviesModels

final class GenreTests: XCTestCase {
    func testGenreInitialization() {
        let genre = Genre(id: 1, name: "Action")

        XCTAssertEqual(genre.id, 1)
        XCTAssertEqual(genre.name, "Action")
    }

    func testGenreEquality() {
        let genre1 = Genre(id: 1, name: "Action")
        let genre2 = Genre(id: 1, name: "Action")
        let genre3 = Genre(id: 2, name: "Comedy")

        XCTAssertEqual(genre1, genre2)
        XCTAssertNotEqual(genre1, genre3)
    }
}
