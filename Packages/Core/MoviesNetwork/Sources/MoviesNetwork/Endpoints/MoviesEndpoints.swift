//
//  MoviesEndpoints.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Foundation
import MoviesDomain

/// Domain-specific endpoints for movie operations
/// Implements EndpointProtocol for type safety and consistency
public enum MoviesEndpoints: EndpointProtocol {
    case list(type: MovieType, page: Int)
    case details(id: Int)
    case search(query: String, page: Int)

    public var path: String {
        switch self {
        case .list(let type, _):
            return "movie/\(type.rawValue)"
        case .details(let id):
            return "movie/\(id)"
        case .search:
            return "search/movie"
        }
    }

    public var queryParameters: [URLQueryItem] {
        switch self {
        case .search(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
            ]
        case .list(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        default:
            return []
        }
    }
}

/// Convenience extension for creating movie endpoints
public extension MoviesEndpoints {
    /// Create endpoint for listing movies by type
    /// - Parameter type: The type of movies to fetch
    /// - Returns: Configured endpoint
    static func movies(type: MovieType, page: Int = 1) -> MoviesEndpoints {
        .list(type: type, page: page)
    }

    /// Create endpoint for movie details
    /// - Parameter id: Movie ID
    /// - Returns: Configured endpoint
    static func movieDetails(id: Int) -> MoviesEndpoints {
        .details(id: id)
    }

    /// Create endpoint for movie search
    /// - Parameter query: Search query
    /// - Returns: Configured endpoint
    static func searchMovies(query: String, page: Int = 1) -> MoviesEndpoints {
        .search(query: query, page: page)
    }
}
