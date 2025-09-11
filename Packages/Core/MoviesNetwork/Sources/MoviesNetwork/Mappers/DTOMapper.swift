//
//  DTOMapper.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import MoviesDomain

/// Mapper for converting between DTOs and Domain Models
/// Infrastructure layer - handles data transformation between API and domain
public enum DTOMapper {
    /// Convert MovieDTO to Domain Movie
    public static func toDomain(_ dto: MovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            genreIds: dto.genreIds,
            genres: dto.genres?.map(toDomain)
        )
    }

    /// Convert GenreDTO to Domain Genre
    public static func toDomain(_ dto: GenreDTO) -> Genre {
        Genre(id: dto.id, name: dto.name)
    }

    /// Convert MovieDetailsDTO to Domain MovieDetails
    public static func toDomain(_ dto: MovieDetailsDTO) -> MovieDetails {
        MovieDetails(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            runtime: dto.runtime,
            genres: dto.genres.map(toDomain),
            tagline: dto.tagline
        )
    }

    /// Convert array of MovieDTO to array of Domain Movie
    public static func toDomain(_ dtos: [MovieDTO]) -> [Movie] {
        dtos.map(toDomain)
    }

    /// Convert array of GenreDTO to array of Domain Genre
    public static func toDomain(_ dtos: [GenreDTO]) -> [Genre] {
        dtos.map(toDomain)
    }
}
