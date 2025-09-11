import Foundation

public extension LocalizedStringResource {
    enum DetailsL10n {
        public static let notFound = LocalizedStringResource(
            "details.not_found",
            table: "Details",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let title = LocalizedStringResource(
            "details.title",
            table: "Details",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
