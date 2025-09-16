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

    /// Add movie to favorites
    func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Remove movie from favorites
    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Check if movie is favorited
    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

///  Combine-based storage backed by SwiftData. Local-only,
public final class FavoritesLocalDataSource: FavoritesLocalDataSourceProtocol {
    private let container: ModelContainer
    private let persistenceQueue = DispatchQueue(label: "com.movies.persistence", qos: .userInitiated)

    public init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
        } else {
            // Create a private container if one isn't injected (app can inject its own)
            do {
                self.container = try ModelContainer(for: FavoriteMovie.self)
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
                let descriptor = FetchDescriptor<FavoriteMovie>(
                    sortBy: [SortDescriptor(\FavoriteMovie.createdAt, order: .reverse)]
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

    public func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(())) }
            do {
                let context = ModelContext(self.container)
                var descriptor = FetchDescriptor<FavoriteMovie>(
                    predicate: #Predicate { $0.movieId == movieId },
                    sortBy: []
                )
                descriptor.fetchLimit = 1
                if try context.fetch(descriptor).first == nil {
                    context.insert(FavoriteMovie(movieId: movieId))
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

    public func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return promise(.success(())) }
            do {
                let context = ModelContext(self.container)
                var descriptor = FetchDescriptor<FavoriteMovie>(
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
                var descriptor = FetchDescriptor<FavoriteMovie>(
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
}
