//
//  Constants.swift
//  MoviesUtilities
//
//  Created by User on 9/10/25.
//

import Foundation

/// Legacy constants for backward compatibility
/// TODO: Migrate to NetworkingConfig when implementing full networking layer
public enum Constants {
    public static let tmdbBaseURL = "https://api.themoviedb.org/3"
    public static let tmdbImageBaseURL = "https://image.tmdb.org/t/p"
    public static let tmdbAPIKey = "abfabb9de9dc58bb436d38f97ce882bc"

    public enum ImageSize: String {
        case small = "/w185"
        case medium = "/w500"
        case large = "/w780"
        case original = "/original"
    }
}
