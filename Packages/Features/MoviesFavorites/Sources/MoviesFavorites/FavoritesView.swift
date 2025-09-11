//
//  FavoritesView.swift
//  MoviesFavorites
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesDesignSystem
import MoviesDomain
import MoviesPersistence
import MoviesNavigation

/// Main view for displaying favorite movies
public struct FavoritesView: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var showingSortSheet = false
    @StateObject private var viewModel: FavoritesViewModel

    public init(repository: MovieRepositoryProtocol, favoriteStore: FavoritesStore) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(repository: repository, favoritesStore: favoriteStore))
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading favorites...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else if viewModel.items.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "heart.fill",
                    description: Text("Tap the heart on a movie to add it here.")
                )
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            } else {
                CardGridView(items: viewModel.items,
                             onTap: { item in appRouter.navigateToMovieDetails(movieId: item.id) },
                             onFavoriteToggle: { item in viewModel.toggleFavorite(item.id); viewModel.reload() },
                             isFavorite: { item in viewModel.isFavorite(item.id) })
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .movieSortToolbar(isPresented: $showingSortSheet) { order in
            viewModel.setSortOrder(order)
        }
        .onAppear { viewModel.reload() }
        .onChange(of: viewModel.isLoading) { _, _ in }
    }
}
