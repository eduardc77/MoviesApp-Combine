//
//  MovieSortOrder.swift
//  MoviesDomain
//
//  Created by User on 9/10/25.
//

import Foundation
import SharedModels

/// Canonical sort orders supported by the app for movie lists
public enum MovieSortOrder: String, CaseIterable, Identifiable, Sendable, SortOption {
    case ratingAscending
    case ratingDescending
    case releaseDateAscending
    case releaseDateDescending

    public var id: String { String(localized: labelKey) }

    /// Localized display title used by UI
    public var labelKey: LocalizedStringResource {
        switch self {
        case .ratingAscending: return .DomainL10n.ratingAscending
        case .ratingDescending: return .DomainL10n.ratingDescending
        case .releaseDateAscending: return .DomainL10n.releaseDateAscending
        case .releaseDateDescending: return .DomainL10n.releaseDateDescending
        }
    }

    /// Display name for the SortOption protocol
    public var displayName: String {
        String(localized: labelKey)
    }

    /// TMDB server-side sort parameter value for endpoints that support it
    public var tmdbSortValue: String {
        switch self {
        case .ratingAscending: return "vote_average.asc"
        case .ratingDescending: return "vote_average.desc"
        case .releaseDateAscending: return "release_date.asc"
        case .releaseDateDescending: return "release_date.desc"
        }
    }
}

public extension Array where Element == Movie {
    /// Returns a new array sorted by the provided order
    func sorted(by order: MovieSortOrder) -> [Movie] {
        switch order {
        case .ratingAscending:
            return self.sorted { $0.voteAverage < $1.voteAverage }
        case .ratingDescending:
            return self.sorted { $0.voteAverage > $1.voteAverage }
        case .releaseDateAscending:
            // Dates are ISO-8601 (YYYY-MM-DD) so lexical compare is fine
            return self.sorted { $0.releaseDate < $1.releaseDate }
        case .releaseDateDescending:
            return self.sorted { $0.releaseDate > $1.releaseDate }
        }
    }
}
