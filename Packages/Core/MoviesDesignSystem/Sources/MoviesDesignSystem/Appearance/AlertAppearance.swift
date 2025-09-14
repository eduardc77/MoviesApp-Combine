//
//  AlertAppearance.swift
//  MoviesDesignSystem
//
//  Centralized UIAppearance configuration for UIAlertController (used by confirmation dialogs)
//

#if canImport(UIKit)
import UIKit
#endif

public enum AlertAppearance {
    /// Configure global appearance for UIAlertController (confirmation dialogs, alerts)
    @MainActor public static func configure() {
        #if canImport(UIKit)

        // MARK: Alert Action Buttons
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label

        #else
        // No-op on non-UIKit platforms (e.g., macOS when running SwiftPM tests)
        #endif
    }
}
