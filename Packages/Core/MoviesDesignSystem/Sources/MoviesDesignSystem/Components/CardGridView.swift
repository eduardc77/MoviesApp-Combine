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
    private let onLoadNext: (() -> Void)?
    private let showLoadingOverlay: Bool

    @State private var hasTriggeredLoadNext = false

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 140, maximum: 220), spacing: 8, alignment: .top)
    ]

    public init(
        items: [Item],
        onTap: @escaping (Item) -> Void,
        onFavoriteToggle: @escaping (Item) -> Void,
        isFavorite: @escaping (Item) -> Bool,
        onLoadNext: (() -> Void)? = nil,
        showLoadingOverlay: Bool = false
    ) {
        self.items = items
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
        self.isFavorite = isFavorite
        self.onLoadNext = onLoadNext
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
                    .onAppear {
                        if let index = items.firstIndex(where: { $0.idKey == item.idKey }),
                           index >= items.count - 3 && !hasTriggeredLoadNext {
                            hasTriggeredLoadNext = true
                            onLoadNext?()
                        }
                    }
                }
            }
            .padding(10)

            if showLoadingOverlay {
                footerLoadingIndicator
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: items.count) { _, _ in
            hasTriggeredLoadNext = false // Reset when items count changes
        }
        .background(Color.secondary.opacity(0.4))
    }

    var footerLoadingIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
            Text(.DesignSystemL10n.loadingMore)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
// Helper to access id property without requiring Identifiable conformance
private extension CardDisplayable {
    var idKey: Int { id }
}
