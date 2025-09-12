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
            if let error = viewModel.error {
                VStack(spacing: 16) {
                    Text("Favorites Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Try Again") {
                        viewModel.reload()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if canImport(UIKit)
                .background(Color(.systemGray6))
                #else
                .background(Color.gray.opacity(0.2))
                #endif
            } else if viewModel.isLoading {
                LoadingView()
                #if canImport(UIKit)
                .background(Color(.systemGray6))
                #else
                .background(Color.gray.opacity(0.2))
                #endif
            } else if viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: .FavoritesL10n.emptyTitle), systemImage: "heart.fill")
                } description: {
                    Text(.FavoritesL10n.emptyDescription)
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
                             onFavoriteToggle: { item in viewModel.toggleFavorite(item.id); viewModel.reload() },
                             isFavorite: { item in viewModel.isFavorite(item.id) })
            }
        }
        .navigationTitle(Text(.FavoritesL10n.title))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .movieSortToolbar(
            isPresented: $showingSortSheet,
            currentSortOrder: viewModel.sortOrder
        ) { order in
            viewModel.setSortOrder(order)
        }
        .onAppear { viewModel.reload() }
        .onChange(of: viewModel.isLoading) { _, _ in }
    }
}
