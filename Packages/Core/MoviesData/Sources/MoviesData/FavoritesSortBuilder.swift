//
//  FavoritesSortBuilder.swift
//  MoviesData
//
//  Created by Assistant on 9/23/25.
//

import Foundation
import SwiftData
import MoviesDomain

enum FavoritesSortBuilder {
    static func descriptors(for sortOrder: MovieSortOrder?) -> [SortDescriptor<FavoriteMovieEntity>] {
        var sortDescriptors: [SortDescriptor<FavoriteMovieEntity>] = []
        if let order = sortOrder {
            switch order {
            case .popularityAscending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.popularity, order: .forward))
            case .popularityDescending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.popularity, order: .reverse))
            case .ratingAscending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.voteAverage, order: .forward))
            case .ratingDescending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.voteAverage, order: .reverse))
            case .releaseDateAscending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.releaseDate, order: .forward))
            case .releaseDateDescending:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.releaseDate, order: .reverse))
            case .recentlyAdded:
                sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.createdAt, order: .reverse))
            }
        } else {
            // Default: recently added first
            sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.createdAt, order: .reverse))
        }
        // Deterministic tie-breaker
        sortDescriptors.append(SortDescriptor(\FavoriteMovieEntity.movieId, order: .forward))
        return sortDescriptors
    }
}



