//
//  FavoritesStoreProtocol.swift
//  MoviesDomain
//
//  Created by User on 9/14/25.
//

import Combine

/// Read-only favorites interface for UI/state observation
@MainActor
public protocol FavoritesStoreProtocol: Sendable {
    /// Reactive set of favorite movie IDs; intended to be observed via Observation
    var favoriteMovieIds: Set<Int> { get }

    /// Convenience helper for sync favorite check
    func isFavorite(movieId: Int) -> Bool

    // Save snapshots
    func addToFavorites(movie: Movie)
    func addToFavorites(details: MovieDetails)
    // Remove favorite by id
    func removeFromFavorites(movieId: Int)

    /// Fetch locally stored favorite details snapshot if available
    func getFavoriteDetails(movieId: Int) -> MovieDetails?

    func toggleFavorite(movieId: Int, in items: [Movie]) -> Bool
    func toggleFavorite(movieId: Int, movieDetails: MovieDetails?) -> Bool

    // Background-friendly fetch for potentially large favorites sets
    // Heavy work is performed off-main and delivered as Combine publishers
    func fetchAllFavorites(sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Never>

    // Keyset pagination API
    func fetchFirstPage(sortOrder: MovieSortOrder, pageSize: Int) -> AnyPublisher<(items: [Movie], cursor: FavoritesPageCursor?), Never>
    func fetchNextPage(cursor: FavoritesPageCursor, pageSize: Int) -> AnyPublisher<(items: [Movie], cursor: FavoritesPageCursor?), Never>
}
