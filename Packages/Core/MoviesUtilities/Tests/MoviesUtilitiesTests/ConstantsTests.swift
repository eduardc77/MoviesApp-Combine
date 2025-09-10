import XCTest
@testable import MoviesUtilities

final class ConstantsTests: XCTestCase {
    func testTMDBBaseURL() {
        XCTAssertEqual(Constants.tmdbBaseURL, "https://api.themoviedb.org/3")
    }

    func testTMDBImageBaseURL() {
        XCTAssertEqual(Constants.tmdbImageBaseURL, "https://image.tmdb.org/t/p")
    }

    func testTMDBAPIKey() {
        XCTAssertEqual(Constants.tmdbAPIKey, "abfabb9de9dc58bb436d38f97ce882bc")
    }

    func testImageSizePaths() {
        XCTAssertEqual(Constants.ImageSize.small.rawValue, "/w185")
        XCTAssertEqual(Constants.ImageSize.medium.rawValue, "/w500")
        XCTAssertEqual(Constants.ImageSize.large.rawValue, "/w780")
        XCTAssertEqual(Constants.ImageSize.original.rawValue, "/original")
    }
}
