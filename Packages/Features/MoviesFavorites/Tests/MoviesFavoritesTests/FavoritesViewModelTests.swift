import XCTest
import Combine
@testable import MoviesFavorites
@testable import MoviesDomain
@testable import MoviesPersistence

private final class RepoMock: MovieRepositoryProtocol {
    func fetchMovies(type: MovieType) -> AnyPublisher<[Movie], Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovies(type: MovieType, page: Int, sortBy: MovieSortOrder?) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func searchMovies(query: String) -> AnyPublisher<[Movie], Error> { fatalError() }
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviePage, Error> { fatalError() }
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        let details = MovieDetails(id: id, title: "Movie \(id)", overview: "Detailed overview for movie \(id)", posterPath: "/poster\(id).jpg", backdropPath: "/backdrop\(id).jpg", releaseDate: "2023-01-01", voteAverage: 7.5, voteCount: 100, runtime: 120, genres: [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")], tagline: "An epic adventure")
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
