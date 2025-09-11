//
//  AppRouter.swift
//  MoviesNavigation
//
//  Created by User on 9/10/25.
//

import Foundation
import SwiftUI
import MoviesDomain
import Observation

/// Main app router for navigation coordination
/// Handles all navigation across the app with clean separation
@MainActor
@Observable
public final class AppRouter {
    // Navigation paths for each main section
    public var homePath = NavigationPath()
    public var searchPath = NavigationPath()
    public var favoritesPath = NavigationPath()
    /// Currently selected tab for routing context
    public var selectedTab: AppTab = .home

    public init() {}

    // MARK: - Navigation Methods

    /// Append a destination onto the active tab's path
    public func navigate(to destination: AppDestination) {
        switch selectedTab {
        case .home:
            homePath.append(destination)
        case .search:
            searchPath.append(destination)
        case .favorites:
            favoritesPath.append(destination)
        }
    }

    /// Navigate to movie details by ID on the active tab's stack
    public func navigateToMovieDetails(movieId: Int) {
        navigate(to: .movieDetails(id: movieId))
    }

    /// Clear navigation and go to root
    public func goToRoot() {
        homePath.removeLast(homePath.count)
        searchPath.removeLast(searchPath.count)
        favoritesPath.removeLast(favoritesPath.count)
    }

    /// Go back one level
    public func goBack() {
        if !homePath.isEmpty {
            homePath.removeLast()
        } else if !searchPath.isEmpty {
            searchPath.removeLast()
        } else if !favoritesPath.isEmpty {
            favoritesPath.removeLast()
        }
    }

    // MARK: - Deep Link Handling

    /// Handle deep links
    public func handleDeepLink(_ deepLink: AppDeepLink) -> DeepLinkResult {
        switch deepLink {
        case .movieDetails(let movieId):
            return .navigateToMovie(movieId)
        case .search(let query):
            return .navigateToSearch(query)
        case .tab(let tab):
            return .switchToTab(tab)
        }
    }
}
