//
//  FavoritesStoreProtocol.swift
//  MoviesDomain
//
//  Created by User on 9/14/25.
//

/// Read-only favorites interface for UI/state observation
@MainActor
public protocol FavoritesStoreProtocol: Sendable {
    /// Reactive set of favorite movie IDs; intended to be observed via Observation
    var favoriteMovieIds: Set<Int> { get }

    /// Convenience helper for sync favorite check
    func isFavorite(movieId: Int) -> Bool

    // Toggle favorite status
    func toggleFavorite(movieId: Int)
}
