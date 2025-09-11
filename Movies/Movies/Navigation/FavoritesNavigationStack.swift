//
//  FavoritesNavigationStack.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesNavigation
import MoviesFavorites

/// Navigation stack for the Favorites tab
public struct FavoritesNavigationStack: View {
    @Environment(AppRouter.self) private var appRouter
    @Environment(AppEnvironment.self) private var appEnvironment

    public init() {}

    public var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.favoritesPath) {
            FavoritesView(repository: appEnvironment.movieRepository, favoriteStore: appEnvironment.favoritesStore)
                .withAppDestinations()
        }
    }
}
