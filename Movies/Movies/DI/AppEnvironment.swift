//
//  AppEnvironment.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import Foundation
import MoviesNetwork
import MoviesPersistence
import MoviesDomain
import MoviesUtilities

/// Main dependency injection container for the Movies app
/// Handles configuration loading and dependency wiring
@MainActor
@Observable
public final class AppEnvironment {
    // MARK: - Public Dependencies

    /// Repository for movie operations
    public let movieRepository: MovieRepositoryProtocol

    /// Store for managing favorite movies (reactive layer with persistence)
    public let favoritesStore: FavoritesStore

    /// Networking configuration (exposed for debugging)
    public let networkingConfig: NetworkingConfig

    // MARK: - Initialization

    /// Initializes the app environment
    public init() {
        self.networkingConfig = TMDBNetworkingConfig.config
        self.movieRepository = TMDBMovieRepository.development()

        // Initialize store (reactive layer)
        self.favoritesStore = FavoritesStore()
    }

    /// Convenience initializer for testing with custom dependencies
    /// - Parameters:
    ///   - movieRepository: Custom movie repository (for testing)
    ///   - networkingConfig: Custom networking config (for testing)
    public init(
        movieRepository: MovieRepositoryProtocol,
        networkingConfig: NetworkingConfig
    ) {
        self.movieRepository = movieRepository
        self.favoritesStore = FavoritesStore()
        self.networkingConfig = networkingConfig
    }
}


