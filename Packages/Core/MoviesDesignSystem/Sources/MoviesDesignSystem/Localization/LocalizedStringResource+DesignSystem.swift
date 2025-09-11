//
//  LocalizedStringResource+DesignSystem.swift
//  MoviesDesignSystem
//
//  Shared, reusable localized strings for UI elements across modules
//

//
//  LocalizedStringResource+DesignSystem.swift
//  MoviesDesignSystem
//
//  Created by User on 9/11/25.
//

import Foundation

public extension LocalizedStringResource {
    enum DesignSystemL10n {
        public static let loading = LocalizedStringResource(
            "ds.loading",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let updated = LocalizedStringResource(
            "ds.updated",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let loadingMore = LocalizedStringResource(
            "ds.loading_more",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let none = LocalizedStringResource(
            "ds.none",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
