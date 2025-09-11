//
//  HomeView.swift
//  MoviesHome
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesNavigation
import MoviesPersistence
import MoviesDomain
import MoviesDesignSystem

public struct HomeView: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var viewModel: HomeViewModel

    @State private var selectedTab: HomeCategory = .nowPlaying
    @State private var showingSortSheet = false

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    public init(repository: MovieRepositoryProtocol, favoriteStore: FavoritesStore) {
        _viewModel = State(initialValue: HomeViewModel(repository: repository, favoritesStore: favoriteStore))
    }

    public var body: some View {
        // Simple matched-geometry underline; no measurement needed
        VStack(spacing: 0) {
            // Simple, reusable top filter bar
            TopFilterBar<HomeCategory>(
                currentFilter: $selectedTab,
                activeColor: .white,
                inactiveColor: .white.opacity(0.6),
                underlineColor: .white
            )
            .background(Color.black)

            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView("Loading movies...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TabView(selection: $selectedTab) {
                    ForEach(HomeCategory.allCases) { category in
                        CardGridView(
                            items: viewModel.items,
                            onTap: { appRouter.navigateToMovieDetails(movieId: $0.id) },
                            onFavoriteToggle: { viewModel.toggleFavorite($0.id) },
                            isFavorite: { viewModel.isFavorite($0.id) },
                            onItemAppear: { viewModel.loadNextIfNeeded(currentItem: $0) },
                            showLoadingOverlay: viewModel.isLoadingNext
                        )
                        .tag(category)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .movieSortToolbar(isPresented: $showingSortSheet) { order in
            viewModel.setSortOrder(order)
        }
        .onAppear {
            if viewModel.items.isEmpty {
                viewModel.category = .nowPlaying
                viewModel.load(reset: true)
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            switch newTab {
            case .nowPlaying: viewModel.category = .nowPlaying; viewModel.load(reset: true)
            case .popular: viewModel.category = .popular; viewModel.load(reset: true)
            case .topRated: viewModel.category = .topRated; viewModel.load(reset: true)
            case .upcoming: viewModel.category = .upcoming; viewModel.load(reset: true)
            }
        }
    }
}
