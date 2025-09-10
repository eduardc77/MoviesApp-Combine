import XCTest
@testable import MoviesModels

final class MovieTests: XCTestCase {
    func testMovieInitialization() {
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 100
        )

        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.releaseYear, "2023")
    }

    func testMoviePosterURL() {
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: nil,
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 100
        )

        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w500/test.jpg")
        XCTAssertEqual(movie.posterURL, expectedURL)
    }

    func testMovieBackdropURL() {
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: nil,
            backdropPath: "/backdrop.jpg",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 100
        )

        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w780/backdrop.jpg")
        XCTAssertEqual(movie.backdropURL, expectedURL)
    }

    func testMovieEquality() {
        let movie1 = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 100
        )

        let movie2 = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 100
        )

        XCTAssertEqual(movie1, movie2)
    }
}
