//
//  MoviesApp.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesDesignSystem
import MoviesUtilities
import MoviesNavigation

@main
struct MoviesApp: App {
    /// Main dependency injection container
    private let appEnvironment: AppEnvironment
    /// Main app router for navigation
    private let appRouter: AppRouter

    init() {
        // Configure Kingfisher for optimal movie image loading
        KingfisherConfig.configure()
        // Configure global navigation/tab appearance
        NavigationAppearance.configure()

        self.appEnvironment = AppEnvironment()

        // Initialize app router
        self.appRouter = AppRouter()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appRouter)
                .environment(appEnvironment)
                .environment(appEnvironment.favoritesStore)
        }
    }
}
