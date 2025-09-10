//
//  MovieDetails.swift
//  MoviesModels
//
//  Created by User on 9/10/25.
//

import Foundation

public struct MovieDetails: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String
    public let voteAverage: Double
    public let voteCount: Int
    public let runtime: Int?
    public let genres: [Genre]
    public let tagline: String?

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String,
        voteAverage: Double,
        voteCount: Int,
        runtime: Int?,
        genres: [Genre],
        tagline: String?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.genres = genres
        self.tagline = tagline
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    public var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    public var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
    }

    public var releaseYear: String {
        String(releaseDate.prefix(4))
    }

    public var displayGenres: [Genre] {
        Array(genres.prefix(2))
    }
}
