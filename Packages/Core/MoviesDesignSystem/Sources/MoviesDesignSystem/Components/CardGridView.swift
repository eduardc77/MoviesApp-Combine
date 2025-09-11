//
//  CardGridView.swift
//  MoviesDesignSystem
//
//  Reusable grid for displaying CardDisplayable items using GenericCardView
//

import SwiftUI

public struct CardGridView<Item: CardDisplayable>: View {
    private let items: [Item]
    private let onTap: (Item) -> Void
    private let onFavoriteToggle: (Item) -> Void
    private let isFavorite: (Item) -> Bool
    private let onItemAppear: ((Item) -> Void)?
    private let showLoadingOverlay: Bool

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 140, maximum: 220), spacing: 8, alignment: .top)
    ]

    public init(
        items: [Item],
        onTap: @escaping (Item) -> Void,
        onFavoriteToggle: @escaping (Item) -> Void,
        isFavorite: @escaping (Item) -> Bool,
        onItemAppear: ((Item) -> Void)? = nil,
        showLoadingOverlay: Bool = false
    ) {
        self.items = items
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
        self.isFavorite = isFavorite
        self.onItemAppear = onItemAppear
        self.showLoadingOverlay = showLoadingOverlay
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items, id: \.idKey) { item in
                    GenericCardView(
                        item: item,
                        onTap: { onTap(item) },
                        onFavoriteToggle: { onFavoriteToggle(item) },
                        isFavorite: { isFavorite(item) }
                    )
                    .onAppear { onItemAppear?(item) }
                }
            }
            .padding(10)
        }
#if canImport(UIKit)
        .background(Color(.systemGray4))
#else
        .background(Color.gray.opacity(0.2))
#endif

        if showLoadingOverlay {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
                .padding(12)
        }
    }
}

// Helper to access id property without requiring Identifiable conformance
private extension CardDisplayable {
    var idKey: Int { id }
}
