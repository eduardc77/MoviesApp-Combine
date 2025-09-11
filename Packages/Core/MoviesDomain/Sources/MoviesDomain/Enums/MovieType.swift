//
//  MovieType.swift
//  MoviesDomain
//
//  Created by User on 9/10/25.
//

import Foundation

public enum MovieType: String, CaseIterable, Sendable {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming

    public var iconSystemName: String {
        switch self {
        case .nowPlaying: return "play.circle"
        case .popular: return "flame"
        case .topRated: return "star"
        case .upcoming: return "calendar"
        }
    }

    public var labelKey: LocalizedStringResource {
        switch self {
        case .nowPlaying: return .DomainL10n.nowPlaying
        case .popular: return .DomainL10n.popular
        case .topRated: return .DomainL10n.topRated
        case .upcoming: return .DomainL10n.upcoming
        }
    }
}

public enum MovieTypeL10n {
    public static let nowPlaying = LocalizedStringResource(
        "movietype.now_playing",
        table: "Domain",
        bundle: .atURL(Bundle.module.bundleURL)
    )
    public static let popular = LocalizedStringResource(
        "movietype.popular",
        table: "Domain",
        bundle: .atURL(Bundle.module.bundleURL)
    )
    public static let topRated = LocalizedStringResource(
        "movietype.top_rated",
        table: "Domain",
        bundle: .atURL(Bundle.module.bundleURL)
    )
    public static let upcoming = LocalizedStringResource(
        "movietype.upcoming",
        table: "Domain",
        bundle: .atURL(Bundle.module.bundleURL)
    )
}
