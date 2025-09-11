//
//  HomeNavigationStack.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesNavigation
import MoviesHome

/// Navigation stack for the Home tab
public struct HomeNavigationStack: View {
    @Environment(AppRouter.self) private var appRouter
    @Environment(AppEnvironment.self) private var appEnvironment

    public init() {}

    public var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.homePath) {
            HomeView(repository: appEnvironment.movieRepository, favoriteStore: appEnvironment.favoritesStore)
                .withAppDestinations()
        }
    }
}
