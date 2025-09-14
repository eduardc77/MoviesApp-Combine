import Foundation
import SwiftData

@Model
public final class FavoriteMovie {
    @Attribute(.unique)
    public var movieId: Int
    public var createdAt: Date

    public init(movieId: Int, createdAt: Date = .now) {
        self.movieId = movieId
        self.createdAt = createdAt
    }
}


