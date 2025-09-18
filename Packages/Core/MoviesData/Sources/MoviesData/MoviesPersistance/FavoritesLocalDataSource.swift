//
//  FavoritesLocalDataSource.swift
//  MoviesData
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine
import SwiftData
import MoviesDomain

public protocol FavoritesLocalDataSourceProtocol: Sendable {
    /// Get current favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Add a snapshot of Movie to favorites
    func addToFavorites(movie: Movie) -> AnyPublisher<Void, Error>
    /// Add a snapshot of MovieDetails to favorites
    func addToFavorites(details: MovieDetails) -> AnyPublisher<Void, Error>

    /// Remove movie from favorites
    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Check if movie is favorited
    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error>

    /// Fetch a page of favorited movies from local storage
    func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Error>

    /// Fetch locally stored favorite details snapshot if available
    func getFavoriteDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error>
}

///  Combine-based storage backed by SwiftData.
public final class FavoritesLocalDataSource: FavoritesLocalDataSourceProtocol {
    private let container: ModelContainer
    private let persistenceQueue = DispatchQueue(label: "com.movies.persistence", qos: .userInitiated)

    public init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
        } else {
            // Create a private container if one isn't injected (app can inject its own)
            do {
                self.container = try ModelContainer(for: FavoriteMovieEntity.self, FavoriteGenreEntity.self)
            } catch {
                fatalError("Failed to create ModelContainer for FavoriteMovie: \(error)")
            }
        }
    }

    public func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success([])) }
            do {
                let context = ModelContext(self.container)
                let descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    sortBy: [SortDescriptor(\FavoriteMovieEntity.createdAt, order: .reverse)]
                )
                let rows = try context.fetch(descriptor)
                promise(.success(Set(rows.map { $0.movieId })))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func addToFavorites(movie: Movie) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(())) }
            do {
                let context = ModelContext(self.container)
                let targetId = movie.id
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    predicate: #Predicate { $0.movieId == targetId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                if let existing = try context.fetch(descriptor).first {
                    // Update existing snapshot
                    existing.title = movie.title
                    existing.overview = movie.overview
                    existing.posterPath = movie.posterPath
                    existing.backdropPath = movie.backdropPath
                    existing.releaseDate = movie.releaseDate
                    existing.voteAverage = movie.voteAverage
                    existing.voteCount = movie.voteCount
                    existing.runtime = nil
                    existing.popularity = movie.popularity
                    existing.tagline = nil
                    existing.genres = movie.genres?.map { FavoriteGenreEntity(id: $0.id, name: $0.name) } ?? []
                } else {
                    let genres = movie.genres?.map { FavoriteGenreEntity(id: $0.id, name: $0.name) } ?? []
                    let entity = FavoriteMovieEntity(
                        movieId: movie.id,
                        title: movie.title,
                        overview: movie.overview,
                        posterPath: movie.posterPath,
                        backdropPath: movie.backdropPath,
                        releaseDate: movie.releaseDate,
                        voteAverage: movie.voteAverage,
                        voteCount: movie.voteCount,
                        runtime: nil,
                        popularity: movie.popularity,
                        tagline: nil,
                        genres: genres
                    )
                    context.insert(entity)
                }
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func addToFavorites(details: MovieDetails) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(())) }
            do {
                let context = ModelContext(self.container)
                let targetId = details.id
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    predicate: #Predicate { $0.movieId == targetId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                let genres = details.genres.map { FavoriteGenreEntity(id: $0.id, name: $0.name) }
                if let existing = try context.fetch(descriptor).first {
                    existing.title = details.title
                    existing.overview = details.overview
                    existing.posterPath = details.posterPath
                    existing.backdropPath = details.backdropPath
                    existing.releaseDate = details.releaseDate
                    existing.voteAverage = details.voteAverage
                    existing.voteCount = details.voteCount
                    existing.runtime = details.runtime
                    existing.tagline = details.tagline
                    // Keep existing popularity if any; details may not include it
                    existing.genres = genres
                } else {
                    let entity = FavoriteMovieEntity(
                        movieId: details.id,
                        title: details.title,
                        overview: details.overview,
                        posterPath: details.posterPath,
                        backdropPath: details.backdropPath,
                        releaseDate: details.releaseDate,
                        voteAverage: details.voteAverage,
                        voteCount: details.voteCount,
                        runtime: details.runtime,
                        popularity: 0,
                        tagline: details.tagline,
                        genres: genres
                    )
                    context.insert(entity)
                }
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(())) }
            do {
                let context = ModelContext(self.container)
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    predicate: #Predicate { $0.movieId == movieId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                if let obj = try context.fetch(descriptor).first {
                    context.delete(obj)
                    try context.save()
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(false)) }
            do {
                let context = ModelContext(self.container)
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    predicate: #Predicate { $0.movieId == movieId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                let exists = try context.fetch(descriptor).first != nil
                promise(.success(exists))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func getFavorites(page: Int, pageSize: Int, sortOrder: MovieSortOrder?) -> AnyPublisher<[Movie], Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success([])) }
            do {
                let context = ModelContext(self.container)

                // Build sort descriptors
                var sortDescriptors: [SortDescriptor<FavoriteMovieEntity>] = []
                if let order = sortOrder {
                    switch order {
                    case .popularityAscending:
                        sortDescriptors.append(SortDescriptor(\.popularity, order: .forward))
                    case .popularityDescending:
                        sortDescriptors.append(SortDescriptor(\.popularity, order: .reverse))
                    case .ratingAscending:
                        sortDescriptors.append(SortDescriptor(\.voteAverage, order: .forward))
                    case .ratingDescending:
                        sortDescriptors.append(SortDescriptor(\.voteAverage, order: .reverse))
                    case .releaseDateAscending:
                        sortDescriptors.append(SortDescriptor(\.releaseDate, order: .forward))
                    case .releaseDateDescending:
                        sortDescriptors.append(SortDescriptor(\.releaseDate, order: .reverse))
                    }
                } else {
                    sortDescriptors.append(SortDescriptor(\.createdAt, order: .reverse))
                }
                // deterministic tie-breaker
                sortDescriptors.append(SortDescriptor(\.movieId, order: .forward))

                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    sortBy: sortDescriptors
                )
                descriptor.fetchLimit = pageSize
                descriptor.fetchOffset = max((page - 1), 0) * pageSize
                let rows = try context.fetch(descriptor)

                let mapped: [Movie] = rows.map { row in
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
                promise(.success(mapped))
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func getFavoriteDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(nil)) }
            do {
                let context = ModelContext(self.container)
                var descriptor = FetchDescriptor<FavoriteMovieEntity>(
                    predicate: #Predicate { $0.movieId == movieId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                if let row = try context.fetch(descriptor).first {
                    let details = MovieDetails(
                        id: row.movieId,
                        title: row.title,
                        overview: row.overview,
                        posterPath: row.posterPath,
                        backdropPath: row.backdropPath,
                        releaseDate: row.releaseDate,
                        voteAverage: row.voteAverage,
                        voteCount: row.voteCount,
                        runtime: row.runtime,
                        genres: row.genres.map { Genre(id: $0.id, name: $0.name) },
                        tagline: row.tagline
                    )
                    promise(.success(details))
                } else {
                    promise(.success(nil))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .subscribe(on: persistenceQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
