//
//  SearchBarAppearance.swift
//  MoviesDesignSystem
//
//  Centralized UIAppearance configuration for SearchBar
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum SearchBarAppearance {
    /// Configure global appearance for SearchBar
    @MainActor public static func configure() {
#if canImport(UIKit)
        // MARK: Search Bar (for SwiftUI .searchable)
        let searchBar = UISearchBar.appearance()
        searchBar.barTintColor = .white
        searchBar.backgroundColor = .black
        searchBar.tintColor = .white

        // Use a bold magnifying glass icon
        let boldSymbol = UIImage.SymbolConfiguration(weight: .bold)
        if let magnifier = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: boldSymbol)?
            .withTintColor(.black, renderingMode: .alwaysOriginal) {
            searchBar.setImage(magnifier, for: .search, state: .normal)
            searchBar.setImage(magnifier, for: .search, state: .highlighted)
        }
        let searchTF = UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchTF.backgroundColor = .white
        searchTF.textColor = .black
        searchTF.tintColor = .black
        searchTF.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
        ]
        // Set search bar icon tint color
        let searchIconImages = UIImageView.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchIconImages.tintColor = .black

#else
        // No-op on non-UIKit platforms (e.g., macOS when running SwiftPM tests)
#endif
    }
}
