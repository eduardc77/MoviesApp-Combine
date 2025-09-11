//
//  SortToolbar.swift
//  MoviesDesignSystem
//
//  Created by User on 9/10/25.
//

import SwiftUI
import MoviesDomain

/// Reusable toolbar + confirmation dialog for sorting movie lists
public struct SortToolbarModifier: ViewModifier {
    @Binding private var isPresented: Bool
    private let onSelect: (MovieSortOrder) -> Void

    public init(
        isPresented: Binding<Bool>,
        onSelect: @escaping (MovieSortOrder) -> Void
    ) {
        self._isPresented = isPresented
        self.onSelect = onSelect
    }

    public func body(content: Content) -> some View {
        content
            .toolbar {
                #if canImport(UIKit)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image("ic_sort", bundle: Bundle.module)
                    }
                    .tint(.white)
                }
                #endif
            }
            .confirmationDialog("Sort movies", isPresented: $isPresented) {
                ForEach(MovieSortOrder.allCases) { order in
                    Button(String(localized: order.labelKey)) { onSelect(order) }
                }
                Button("Cancel", role: .cancel) { }
            }
    }
}

public extension View {
    /// Attach a standard sort toolbar for movie lists
    func movieSortToolbar(isPresented: Binding<Bool>, onSelect: @escaping (MovieSortOrder) -> Void) -> some View {
        self.modifier(SortToolbarModifier(isPresented: isPresented, onSelect: onSelect))
    }
}
