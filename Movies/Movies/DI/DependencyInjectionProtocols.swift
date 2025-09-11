//
//  DependencyInjectionProtocols.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import MoviesDomain
import MoviesPersistence
import MoviesFavorites
import MoviesUtilities

/// Protocol defining the core dependencies needed by the app
/// This allows for easy testing by injecting mock implementations
public protocol DependencyContainer: Sendable {
    /// Repository for movie operations
    var movieRepository: MovieRepositoryProtocol { get }

    /// Store for managing favorite movies (reactive layer with persistence)
    var favoritesStore: FavoritesStore { get }

    /// Networking configuration
    var networkingConfig: NetworkingConfig { get }
}

// Dependency creation helpers
public extension AppEnvironment {
    /// Creates a development environment with all dependencies
    static func development() -> AppEnvironment {
        return AppEnvironment()
    }
}
