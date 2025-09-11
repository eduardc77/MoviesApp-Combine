import XCTest
import Combine
@testable import MoviesFavorites
@testable import MoviesDomain
@testable import MoviesPersistence

private final class RepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        let details = MovieDetails(id: id, title: "T", overview: "", posterPath: nil, backdropPath: nil, releaseDate: "2020-01-01", voteAverage: 5, voteCount: 1, runtime: nil, genres: [], tagline: nil)
        return Just(details).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func testReloadReflectsFavoritesAfterToggle() {
        let repo = RepoMock()
        let store = FavoritesStore()
        let vm = FavoritesViewModel(repository: repo, favoritesStore: store)

        // Initially empty
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertTrue(vm.items.isEmpty)

        // Toggle favorite and reload
        store.toggleFavorite(movieId: 42)
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(vm.items.map { $0.id }, [42])

        // Toggle off and reload
        store.toggleFavorite(movieId: 42)
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertTrue(vm.items.isEmpty)
    }
}
