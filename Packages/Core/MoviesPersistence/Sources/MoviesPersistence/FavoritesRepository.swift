import Foundation
import Combine
import MoviesDomain

/// Adapter that exposes a Combine repository API backed by a local storage
public final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let localDataSource: FavoritesLocalDataSourceProtocol

    public init(localDataSource: FavoritesLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    public func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        localDataSource.getFavoriteMovieIds()
    }

    public func isMovieFavorited(movieId: Int) -> AnyPublisher<Bool, Error> {
        localDataSource.isFavorite(movieId: movieId)
    }

    public func toggleFavorite(movieId: Int) -> AnyPublisher<Void, Error> {
        // Check current to decide add/remove with optimistic UI at store level.
        // Here we just perform a toggle by attempting add then remove if exists fails, or vice versa.
        // Simpler: read favorite flag then route.
        localDataSource.isFavorite(movieId: movieId)
            .flatMap { [localDataSource] isFav -> AnyPublisher<Void, Error> in
                if isFav { return localDataSource.removeFromFavorites(movieId: movieId) }
                else { return localDataSource.addToFavorites(movieId: movieId) }
            }
            .eraseToAnyPublisher()
    }
}


