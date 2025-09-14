import Foundation

public extension LocalizedStringResource {
    enum HomeL10n {
        public static let title = LocalizedStringResource(
            "home.title",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let errorTitle = LocalizedStringResource(
            "home.error_title",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
