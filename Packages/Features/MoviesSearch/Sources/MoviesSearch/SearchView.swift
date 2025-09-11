//
//  SearchView.swift
//  MoviesSearch
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesNavigation
import MoviesPersistence
import MoviesDomain
import MoviesDesignSystem

public struct SearchView: View {
    @Environment(AppRouter.self) private var appRouter
    @StateObject private var viewModel: SearchViewModel
    @State private var showingSortSheet = false

    public init(repository: MovieRepositoryProtocol, favoriteStore: FavoritesStore) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(repository: repository, favoritesStore: favoriteStore))
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Searching...")
            } else if viewModel.items.isEmpty {
                ContentUnavailableView(
                    viewModel.query.isEmpty ? "Search Movies" : "No Results",
                    systemImage: viewModel.query.isEmpty ? "magnifyingglass" : "film",
                    description: Text(viewModel.query.isEmpty ?
                                      "Type to search for movies":
                                        "Try a different query or spelling."
                                     )
                )
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            } else {
                CardGridView(items: viewModel.items,
                             onTap: { item in appRouter.navigateToMovieDetails(movieId: item.id) },
                             onFavoriteToggle: { item in viewModel.toggleFavorite(item.id) },
                             isFavorite: { item in viewModel.isFavorite(item.id) },
                             onItemAppear: { item in viewModel.loadNextIfNeeded(currentItem: item) },
                             showLoadingOverlay: viewModel.isLoadingNext)
            }
        }

        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Movies")
        .onSubmit(of: .search) {
            viewModel.search(reset: true)
        }
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .movieSortToolbar(isPresented: $showingSortSheet) { order in
            viewModel.setSortOrder(order)
        }
    }
}
