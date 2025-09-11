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
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // critical: fills stretchy box
                        .clipped()
                    }
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.35), .clear],
                                       startPoint: .bottom, endPoint: .center)
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        // Poster and basic info
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

                                // Genre chips (up to 3)
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
            }
            .coordinateSpace(name: "detailScroll")
            .navigationTitle(movie.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Group {
                            if viewModel.isFavorite() {
                                Image(ds: .heartFill)
                                    .resizable()
                                    .renderingMode(.original)
                            } else {
                                Image(ds: .heart)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(Color(.systemBackground))
                            }
                        }
                        .frame(width: 20, height: 20)
                        .transition(.scale)
                    }

                }
            }
        } else {
            // Movie not found
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading movie...")
                } else {
                    Text("Movie not found")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
