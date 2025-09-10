//
//  MovieType.swift
//  MoviesModels
//
//  Created by User on 9/10/25.
//

import Foundation

public enum MovieType: String, CaseIterable {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming

    public var displayName: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .popular: return "Popular"
        case .topRated: return "Top Rated"
        case .upcoming: return "Upcoming"
        }
    }
}
