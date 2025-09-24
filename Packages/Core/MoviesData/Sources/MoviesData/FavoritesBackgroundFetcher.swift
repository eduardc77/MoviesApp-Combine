//
//  FavoritesBackgroundFetcher.swift
//  MoviesData
//
//  Created by Assistant on 9/23/25.
//

import Foundation
import Combine
import SwiftData
import MoviesDomain

/// A background worker that performs SwiftData fetches off the main actor and exposes Combine publishers
final class FavoritesBackgroundFetcher {
    private let container: ModelContainer
    private let backgroundQueue: DispatchQueue

    init(container: ModelContainer) {
        self.container = container
        self.backgroundQueue = DispatchQueue(label: "favorites.background.fetcher", qos: .userInitiated)
    }

    func fetchAllFavorites(sortedBy sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Never> {
        Deferred { [container] in
            Future<[Movie], Never> { promise in
                let context = ModelContext(container)
                let sortDescriptors = FavoritesSortBuilder.descriptors(for: sortOrder)
                let descriptor = FetchDescriptor<FavoriteMovieEntity>(sortBy: sortDescriptors)
                do {
                    let rows = try context.fetch(descriptor)
                    let items = rows.map { row in
                        Movie(
                            id: row.movieId,
                            title: row.title,
                            overview: row.overview,
                            posterPath: row.posterPath,
                            backdropPath: row.backdropPath,
                            releaseDate: row.releaseDate,
                            voteAverage: row.voteAverage,
                            voteCount: row.voteCount,
                            genres: row.genres.map { Genre(id: $0.id, name: $0.name) },
                            popularity: row.popularity ?? 0
                        )
                    }
                    promise(.success(items))
                } catch {
                    promise(.success([]))
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .eraseToAnyPublisher()
    }

    func fetchFirstPage(sortedBy sortOrder: MovieSortOrder, pageSize: Int) -> AnyPublisher<(items: [Movie], cursor: FavoritesPageCursor?), Never> {
        Deferred { [container] in
            Future<(items: [Movie], cursor: FavoritesPageCursor?), Never> { promise in
                let context = ModelContext(container)
                let sortDescriptors = FavoritesSortBuilder.descriptors(for: sortOrder)
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(sortBy: sortDescriptors)
                descriptor.fetchLimit = pageSize
                descriptor.fetchOffset = 0
                do {
                    let rows = try context.fetch(descriptor)
                    let items = rows.map { row in
                        Movie(
                            id: row.movieId,
                            title: row.title,
                            overview: row.overview,
                            posterPath: row.posterPath,
                            backdropPath: row.backdropPath,
                            releaseDate: row.releaseDate,
                            voteAverage: row.voteAverage,
                            voteCount: row.voteCount,
                            genres: row.genres.map { Genre(id: $0.id, name: $0.name) },
                            popularity: row.popularity ?? 0
                        )
                    }
                    let last = rows.last
                    let cursor: FavoritesPageCursor? = {
                        guard let row = last else { return nil }
                        switch sortOrder {
                        case .recentlyAdded:
                            return .recentlyAdded(lastCreatedAt: row.createdAt, lastMovieId: row.movieId)
                        case .ratingDescending:
                            return .ratingDescending(lastVoteAverage: row.voteAverage, lastMovieId: row.movieId)
                        case .ratingAscending:
                            return .ratingAscending(lastVoteAverage: row.voteAverage, lastMovieId: row.movieId)
                        case .releaseDateDescending:
                            return .releaseDateDescending(lastDate: row.releaseDate, lastMovieId: row.movieId)
                        case .releaseDateAscending:
                            return .releaseDateAscending(lastDate: row.releaseDate, lastMovieId: row.movieId)
                        case .popularityAscending, .popularityDescending:
                            return nil
                        }
                    }()
                    promise(.success((items, cursor)))
                } catch {
                    promise(.success(([], nil)))
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .eraseToAnyPublisher()
    }

    func fetchNextPage(cursor: FavoritesPageCursor, pageSize: Int) -> AnyPublisher<(items: [Movie], cursor: FavoritesPageCursor?), Never> {
        Deferred { [container] in
            Future<(items: [Movie], cursor: FavoritesPageCursor?), Never> { promise in
                let context = ModelContext(container)
                // Derive sort and predicate from cursor
                let (sortOrder, predicate): (MovieSortOrder, Predicate<FavoriteMovieEntity>?) = {
                    switch cursor {
                    case let .recentlyAdded(lastCreatedAt, lastMovieId):
                        let pred = #Predicate<FavoriteMovieEntity> { entity in
                            (entity.createdAt < lastCreatedAt) || (entity.createdAt == lastCreatedAt && entity.movieId > lastMovieId)
                        }
                        return (.recentlyAdded, pred)
                    case let .ratingDescending(lastVote, lastId):
                        let pred = #Predicate<FavoriteMovieEntity> { entity in
                            (entity.voteAverage < lastVote) || (entity.voteAverage == lastVote && entity.movieId > lastId)
                        }
                        return (.ratingDescending, pred)
                    case let .ratingAscending(lastVote, lastId):
                        let pred = #Predicate<FavoriteMovieEntity> { entity in
                            (entity.voteAverage > lastVote) || (entity.voteAverage == lastVote && entity.movieId > lastId)
                        }
                        return (.ratingAscending, pred)
                    case let .releaseDateDescending(lastDate, lastId):
                        let pred = #Predicate<FavoriteMovieEntity> { entity in
                            (entity.releaseDate < lastDate) || (entity.releaseDate == lastDate && entity.movieId > lastId)
                        }
                        return (.releaseDateDescending, pred)
                    case let .releaseDateAscending(lastDate, lastId):
                        let pred = #Predicate<FavoriteMovieEntity> { entity in
                            (entity.releaseDate > lastDate) || (entity.releaseDate == lastDate && entity.movieId > lastId)
                        }
                        return (.releaseDateAscending, pred)
                    }
                }()

                let sortDescriptors = FavoritesSortBuilder.descriptors(for: sortOrder)
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(predicate: predicate, sortBy: sortDescriptors)
                descriptor.fetchLimit = pageSize
                do {
                    let rows = try context.fetch(descriptor)
                    let items = rows.map { row in
                        Movie(
                            id: row.movieId,
                            title: row.title,
                            overview: row.overview,
                            posterPath: row.posterPath,
                            backdropPath: row.backdropPath,
                            releaseDate: row.releaseDate,
                            voteAverage: row.voteAverage,
                            voteCount: row.voteCount,
                            genres: row.genres.map { Genre(id: $0.id, name: $0.name) },
                            popularity: row.popularity ?? 0
                        )
                    }
                    let last = rows.last
                    let next: FavoritesPageCursor? = {
                        guard let row = last else { return nil }
                        switch sortOrder {
                        case .recentlyAdded:
                            return .recentlyAdded(lastCreatedAt: row.createdAt, lastMovieId: row.movieId)
                        case .ratingDescending:
                            return .ratingDescending(lastVoteAverage: row.voteAverage, lastMovieId: row.movieId)
                        case .ratingAscending:
                            return .ratingAscending(lastVoteAverage: row.voteAverage, lastMovieId: row.movieId)
                        case .releaseDateDescending:
                            return .releaseDateDescending(lastDate: row.releaseDate, lastMovieId: row.movieId)
                        case .releaseDateAscending:
                            return .releaseDateAscending(lastDate: row.releaseDate, lastMovieId: row.movieId)
                        case .popularityAscending, .popularityDescending:
                            return nil
                        }
                    }()
                    promise(.success((items, next)))
                } catch {
                    promise(.success(([], nil)))
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .eraseToAnyPublisher()
    }
}



