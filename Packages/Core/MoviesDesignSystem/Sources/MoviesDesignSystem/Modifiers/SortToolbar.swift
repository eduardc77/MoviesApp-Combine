//
//  SortToolbar.swift
//  MoviesDesignSystem
//
//  Created by User on 9/10/25.
//

import SwiftUI
import SharedModels

/// Generic reusable toolbar + menu for sorting any list
public struct SortToolbarModifier<Option: SortOption>: ViewModifier {
    @Binding private var isPresented: Bool
    private let currentSortOption: Option?
    private let onSelect: (Option) -> Void

    public init(
        isPresented: Binding<Bool>,
        currentSortOption: Option?,
        onSelect: @escaping (Option) -> Void
    ) {
        self._isPresented = isPresented
        self.currentSortOption = currentSortOption
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
                ForEach(Option.allCases) { option in
                    Button {
                        onSelect(option)
                        isPresented = false  // Auto-dismiss after selection
                    } label: {
                        Text("\(currentSortOption?.id == option.id ? "✓" : "") \(option.displayName)")
                    }
                    .tint(Color.primary)
                }
                Button(String(localized: .DesignSystemL10n.cancel), role: .cancel) { }
                    .tint(Color.primary)
            }
    }
}

public extension View {
    /// Attach a generic sort toolbar for any sortable content
    func sortToolbar<Option: SortOption>(
        isPresented: Binding<Bool>,
        currentSortOption: Option?,
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        self.modifier(SortToolbarModifier<Option>(
            isPresented: isPresented,
            currentSortOption: currentSortOption,
            onSelect: onSelect
        ))
    }
}
