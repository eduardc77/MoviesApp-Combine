//
//  MovieDetailView.swift
//  MoviesDetails
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesPersistence
import MoviesDomain
import MoviesDesignSystem

/// Movie details view
public struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel

    public init(movieId: Int, repository: MovieRepositoryProtocol, favoriteStore: FavoritesStore) {
        _viewModel = StateObject(wrappedValue:
            MovieDetailViewModel(
                repository: repository,
                favoritesStore: favoriteStore,
                movieId: movieId
            )
        )
    }

    public var body: some View {
        if let movie = viewModel.movie {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header(for: movie)
                    content(for: movie)
                }
            }
            .coordinateSpace(name: "detailScroll")
            .navigationTitle(movie.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { favoriteToolbar }
        } else {
            notFoundView
        }
    }
}

// MARK: - Subviews
private extension MovieDetailView {
    @ViewBuilder
    func header(for movie: MovieDetails) -> some View {
        StretchyRatioHeader(ratio: 16.0/9.0) {
            Group {
                if let backdropPath = movie.backdropPath {
                    RemoteImageView(
                        movieBackdropPath: backdropPath,
                        contentMode: .fill
                    )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.12))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .overlay(
            LinearGradient(colors: [.black.opacity(0.35), .clear],
                           startPoint: .bottom, endPoint: .center)
        )
    }

    @ViewBuilder
    func content(for movie: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                RemoteImageView(
                    moviePosterPath: movie.posterPath,
                    placeholder: Image(systemName: "film"),
                    contentMode: .fill,
                    targetSize: CGSize(width: 130, height: 180)
                )
                .zIndex(1)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let tagline = movie.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Released in \(movie.releaseYear)")
                            .font(.headline)

                        HStack(spacing: 6) {
                            Image(ds: .star).foregroundStyle(Color.orange)
                            Text("\(movie.voteAverage, specifier: "%.1f") / 10")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("(\(movie.voteCount))")
                                .foregroundStyle(.secondary)
                        }
                        .font(.headline)
                    }

                    genresChips(for: movie)
                }
            }

            Divider()

            Text("Released in \(movie.releaseYear)")
                .font(.headline)

            Text(movie.overview)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    func genresChips(for movie: MovieDetails) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(movie.genres) { genre in
                    Text(genre.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .scrollTargetLayout()
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollClipDisabled()
    }

    @ToolbarContentBuilder
    var favoriteToolbar: some ToolbarContent {
        ToolbarItem(placement: {
            #if os(iOS)
            .navigationBarTrailing
            #else
            .automatic
            #endif
        }()) {
            Button { viewModel.toggleFavorite() } label: {
                if viewModel.isFavorite() {
                    Image(ds: .heartFill)
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                        .transition(.scale)
                } else {
                    Image(ds: .heart)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .transition(.scale)
                        #if os(iOS)
                        .foregroundStyle(Color(.systemBackground))
                        #else
                        .foregroundStyle(.primary)
                        #endif
                }
            }
        }
    }

    @ViewBuilder
    var notFoundView: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                LoadingView()
            } else {
                Text(.DetailsL10n.notFound)
                    .foregroundColor(.gray)
            }
        }
    }
}
