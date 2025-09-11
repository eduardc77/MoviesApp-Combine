import XCTest
import Combine
@testable import MoviesNetwork
@testable import MoviesDomain

private final class NetworkingClientMock: TMDBNetworkingClientProtocol, @unchecked Sendable {
    nonisolated(unsafe) var requestHandler: ((EndpointProtocol) -> AnyPublisher<Any, Error>)?

    nonisolated func request<T>(_ endpoint: EndpointProtocol) -> AnyPublisher<T, Error> where T : Decodable {
        guard let handler = requestHandler else { fatalError("no handler") }
        return handler(endpoint)
            .tryMap { any in
                guard let typed = any as? T else { throw NSError(domain: "type", code: -1) }
                return typed
            }
            .eraseToAnyPublisher()
    }
}

final class TMDBRemoteDataSourceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_fetchMovies_mapsDTOsToDomain() {
        let client = NetworkingClientMock()
        client.requestHandler = { endpoint in
            let dto = MoviesResponseDTO(results: [MovieDTO(id: 1, title: "A", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 7.0, voteCount: 10, genreIds: [1], genres: nil)], page: 1, totalPages: 1, totalResults: 1)
            return Just(dto).setFailureType(to: Error.self).map { $0 as Any }.eraseToAnyPublisher()
        }
        let sut = TMDBRemoteDataSource(networkingClient: client)

        let exp = expectation(description: "mapped")
        sut.fetchMovies(type: .nowPlaying)
            .sink(receiveCompletion: { _ in }, receiveValue: { movies in
                XCTAssertEqual(movies.first?.id, 1)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    func testSearchMoviesPaginationMapsToMoviePage() {
        let client = NetworkingClientMock()
        client.requestHandler = { endpoint in
            let dto = MoviesResponseDTO(results: [], page: 2, totalPages: 5, totalResults: 100)
            return Just(dto).setFailureType(to: Error.self).map { $0 as Any }.eraseToAnyPublisher()
        }
        let sut = TMDBRemoteDataSource(networkingClient: client)

        let exp = expectation(description: "page")
        sut.searchMovies(query: "q", page: 2)
            .sink(receiveCompletion: { _ in }, receiveValue: { page in
                XCTAssertEqual(page.page, 2)
                XCTAssertEqual(page.totalPages, 5)
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    func testFetchMovieDetailsMapsDTOToDomain() {
        let client = NetworkingClientMock()
        client.requestHandler = { endpoint in
            let dto = MovieDetailsDTO(id: 9, title: "X", overview: "o", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 6.5, voteCount: 5, runtime: 100, genres: [GenreDTO(id: 1, name: "Action")], tagline: nil)
            return Just(dto).setFailureType(to: Error.self).map { $0 as Any }.eraseToAnyPublisher()
        }
        let sut = TMDBRemoteDataSource(networkingClient: client)

        let exp = expectation(description: "mapped details")
        sut.fetchMovieDetails(id: 9)
            .sink(receiveCompletion: { _ in }, receiveValue: { details in
                XCTAssertEqual(details.id, 9)
                XCTAssertEqual(details.genres.first?.name, "Action")
                exp.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }
}


