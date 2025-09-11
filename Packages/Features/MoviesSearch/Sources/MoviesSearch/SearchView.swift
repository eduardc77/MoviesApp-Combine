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
                LoadingView()
            } else if viewModel.items.isEmpty {

                ContentUnavailableView {
                    Label(
                        viewModel.isQueryShort ? String(localized: .SearchL10n.emptyTitle) : String(localized: .SearchL10n.noResultsDescription),
                        systemImage: viewModel.isQueryShort ? "magnifyingglass" : "film"
                    )
                } description: {
                    Text(viewModel.isQueryShort ? .SearchL10n.emptyDescription : .SearchL10n.noResultsDescription)
                }
                .frame(maxWidth: .infinity)
                #if canImport(UIKit)
                .background(Color(.systemGray6))
                #else
                .background(Color.gray.opacity(0.2))
                #endif
            } else {
                CardGridView(items: viewModel.items,
                             onTap: { item in appRouter.navigateToMovieDetails(movieId: item.id) },
                             onFavoriteToggle: { item in viewModel.toggleFavorite(item.id) },
                             isFavorite: { item in viewModel.isFavorite(item.id) },
                             onLoadNext: { viewModel.search(reset: false, trigger: .submit) },
                             showLoadingOverlay: viewModel.isLoadingNext)
            }
        }

        .navigationTitle(Text(.SearchL10n.title))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Movies")
        .onSubmit(of: .search) {
            viewModel.search(reset: true, trigger: .submit)
        }
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        #endif
        .movieSortToolbar(isPresented: $showingSortSheet) { order in
            viewModel.setSortOrder(order)
        }
    }
}
