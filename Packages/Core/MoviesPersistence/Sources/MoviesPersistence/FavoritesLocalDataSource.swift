//
//  FavoritesLocalDataSource.swift
//  MoviesPersistence
//
//  Combine-based storage backed by SwiftData. Local-only, thread-safe, no async/await.
//

import Foundation
import Combine
import SwiftData
import MoviesDomain

@MainActor
public protocol FavoritesLocalDataSourceProtocol {
    /// Get current favorite movie IDs
    func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error>

    /// Add movie to favorites
    func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Remove movie from favorites
    func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error>

    /// Check if movie is favorited
    func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

public final class FavoritesLocalDataSource: FavoritesLocalDataSourceProtocol {
    private let container: ModelContainer

    public init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
        } else {
            // Create a private container if one isn't injected (app can inject its own)
            self.container = try! ModelContainer(for: FavoriteMovie.self)
        }
    }

    public func getFavoriteMovieIds() -> AnyPublisher<Set<Int>, Error> {
        Deferred { [weak self] in
            Future { promise in
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
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func addToFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Deferred { [weak self] in
            Future { promise in
                guard let self else { return promise(.success(())) }
                do {
                    let context = ModelContext(self.container)
                    var d = FetchDescriptor<FavoriteMovie>(
                        predicate: #Predicate { $0.movieId == movieId },
                        sortBy: []
                    )
                    d.fetchLimit = 1
                    if try context.fetch(d).first == nil {
                        context.insert(FavoriteMovie(movieId: movieId))
                        try context.save()
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func removeFromFavorites(movieId: Int) -> AnyPublisher<Void, Error> {
        Deferred { [weak self] in
            Future { promise in
                guard let self else { return promise(.success(())) }
                do {
                    let context = ModelContext(self.container)
                    var d = FetchDescriptor<FavoriteMovie>(
                        predicate: #Predicate { $0.movieId == movieId },
                        sortBy: []
                    )
                    d.fetchLimit = 1
                    if let obj = try context.fetch(d).first {
                        context.delete(obj)
                        try context.save()
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func isFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        Deferred { [weak self] in
            Future { promise in
                guard let self else { return promise(.success(false)) }
                do {
                    let context = ModelContext(self.container)
                    var d = FetchDescriptor<FavoriteMovie>(
                        predicate: #Predicate { $0.movieId == movieId },
                        sortBy: []
                    )
                    d.fetchLimit = 1
                    let exists = try context.fetch(d).first != nil
                    promise(.success(exists))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}


