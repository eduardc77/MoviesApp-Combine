//
//  NetworkingConfig.swift
//  MoviesUtilities
//
//  Created by User on 9/10/25.
//

import Foundation

public struct NetworkingConfig: Sendable {
    public let baseURL: URL
    public let apiKey: String
    public let imageBaseURL: URL

    public init(baseURL: URL, apiKey: String, imageBaseURL: URL) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.imageBaseURL = imageBaseURL
    }

    public var apiBaseURL: URL {
        baseURL.appendingPathComponent("3")
    }
}

public enum TMDBNetworkingConfig {
    public static func loadFromInfoPlist() throws -> NetworkingConfig {
        guard let dict = Bundle.main.infoDictionary else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to load Info.plist"]
            )
        }

        guard let tmdb = dict["TMDBConfiguration"] as? [String: Any] else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Missing TMDBConfiguration section in Info.plist"]
            )
        }

        guard let baseURLString = tmdb["TMDBBaseURL"] as? String else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Missing TMDBBaseURL in Info.plist"]
            )
        }

        guard let baseURL = URL(string: baseURLString) else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid TMDBBaseURL format: \(baseURLString)"]
            )
        }

        guard let imageBaseURLString = tmdb["TMDBImageBaseURL"] as? String else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 5,
                userInfo: [NSLocalizedDescriptionKey: "Missing TMDBImageBaseURL in Info.plist"]
            )
        }

        guard let imageBaseURL = URL(string: imageBaseURLString) else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 6,
                userInfo: [NSLocalizedDescriptionKey: "Invalid TMDBImageBaseURL format: \(imageBaseURLString)"]
            )
        }

        guard let apiKey = tmdb["TMDBAPIKey"] as? String, !apiKey.isEmpty else {
            throw NSError(
                domain: "MoviesUtilities",
                code: 7,
                userInfo: [NSLocalizedDescriptionKey: "Missing or empty TMDBAPIKey in Info.plist"]
            )
        }

        return NetworkingConfig(baseURL: baseURL, apiKey: apiKey, imageBaseURL: imageBaseURL)
    }
}
