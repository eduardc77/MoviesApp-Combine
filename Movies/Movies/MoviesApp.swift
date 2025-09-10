//
//  MoviesApp.swift
//  Movies
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesDesignSystem

@main
struct MoviesApp: App {
    init() {
        // Configure Kingfisher for optimal movie image loading
        KingfisherConfig.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
