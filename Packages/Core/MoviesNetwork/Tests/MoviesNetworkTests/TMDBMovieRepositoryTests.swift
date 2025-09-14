import XCTest
import Combine
@testable import MoviesNetwork
@testable import MoviesDomain

private final class RemoteDataSourceMock: MovieRemoteDataSourceProtocol, @unchecked Sendable {
    var fetchMoviesHandler: ((MovieType, Int) -> AnyPublisher<MoviePage, Error>)?
    var fetchMoviesWithSortHandler: ((MovieType, Int, String?) -> AnyPublisher<MoviePage, Error>)?
    var searchMoviesHandler: ((String, Int) -> AnyPublisher<MoviePage, Error>)?
    var detailsHandler: ((Int) -> AnyPublisher<MovieDetails, Error>)?

    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> {
        fetchMovies(type: type, page: 1).map { $0.items }.eraseToAnyPublisher()
    }

    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> {
        guard let h = fetchMoviesHandler else { fatalError("no handler") }
        return h(type, page)
    }

    func fetchMovies(type: MovieType, page: Int, sortBy: String?) -> AnyPublisher<MoviePage, Error> {
        guard let h = fetchMoviesWithSortHandler else { fatalError("no handler") }
        return h(type, page, sortBy)
    }

    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        searchMovies(query: query, page: 1).map { $0.items }.eraseToAnyPublisher()
    }

    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> {
        guard let h = searchMoviesHandler else { fatalError("no handler") }
        return h(query, page)
    }

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        guard let h = detailsHandler else { fatalError("no handler") }
        return h(id)
    }
}

final class TMDBMovieRepositoryPassThroughTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testFetchMoviesPassThrough() {
        let remote = RemoteDataSourceMock()
        remote.fetchMoviesHandler = { type, page in
            let items = [Movie(id: 1, title: "A", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 7, voteCount: 10, genreIds: nil, genres: nil)]
            return Just(MoviePage(items: items, page: page, totalPages: 3)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let repo = MovieRepository(remoteDataSource: remote)

        let exp = expectation(description: "movies")
        repo.fetchMovies(type: .nowPlaying, page: 2)
            .sink(receiveCompletion: { _ in }, receiveValue: { page in
                XCTAssertEqual(page.page, 2)
                XCTAssertEqual(page.totalPages, 3)
                XCTAssertEqual(page.items.first?.id, 1)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    func testSearchMoviesPassThrough() {
        let remote = RemoteDataSourceMock()
        remote.searchMoviesHandler = { query, page in
            XCTAssertEqual(query, "q")
            return Just(MoviePage(items: [], page: page, totalPages: 1)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let repo = MovieRepository(remoteDataSource: remote)

        let exp = expectation(description: "search")
        repo.searchMovies(query: "q", page: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { page in
                XCTAssertEqual(page.page, 1)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    func testFetchMovieDetailsErrorPropagation() {
        enum E: Error { case x }
        let remote = RemoteDataSourceMock()
        remote.detailsHandler = { _ in Fail(error: E.x).eraseToAnyPublisher() }
        let repo = MovieRepository(remoteDataSource: remote)

        let exp = expectation(description: "error")
        repo.fetchMovieDetails(id: 99)
            .sink(receiveCompletion: { completion in
                if case .failure = completion { exp.fulfill() }
            }, receiveValue: { _ in
                XCTFail("should fail")
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }
}
