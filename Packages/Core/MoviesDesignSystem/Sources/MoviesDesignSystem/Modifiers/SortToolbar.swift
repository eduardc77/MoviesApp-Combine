//
//  SortToolbar.swift
//  MoviesDesignSystem
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesDomain

/// Reusable toolbar + menu for sorting movie lists
public struct SortToolbarModifier: ViewModifier {
    @Binding private var isPresented: Bool
    private let currentSortOrder: MovieSortOrder?
    private let onSelect: (MovieSortOrder) -> Void

    public init(
        isPresented: Binding<Bool>,
        currentSortOrder: MovieSortOrder?,
        onSelect: @escaping (MovieSortOrder) -> Void
    ) {
        self._isPresented = isPresented
        self.currentSortOrder = currentSortOrder
        self.onSelect = onSelect
    }

    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image("ic_sort", bundle: Bundle.module)
                    }
                }
            }
            .confirmationDialog(String(localized: .DesignSystemL10n.sortTitle), isPresented: $isPresented) {
                ForEach(MovieSortOrder.allCases) { order in
                    Button {
                        onSelect(order)
                        isPresented = false  // Auto-dismiss after selection
                    } label: {
                        Text("\(currentSortOrder == order ? "✓" : "") \(String(localized: order.labelKey))")
                            .foregroundStyle(.white)
                            .tint(.white)
                    }
                    .foregroundStyle(.white)
                    .tint(.white)
                }
                Button(String(localized: .DesignSystemL10n.cancel), role: .cancel) { }
            }
            .tint(.white)
    }
}

public extension View {
    /// Attach a standard sort toolbar for movie lists
    func movieSortToolbar(
        isPresented: Binding<Bool>,
        currentSortOrder: MovieSortOrder?,
        onSelect: @escaping (MovieSortOrder) -> Void
    ) -> some View {
        self.modifier(SortToolbarModifier(
            isPresented: isPresented,
            currentSortOrder: currentSortOrder,
            onSelect: onSelect
        ))
    }
}
