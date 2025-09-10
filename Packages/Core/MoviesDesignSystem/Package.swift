// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesDesignSystem",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesDesignSystem",
            targets: ["MoviesDesignSystem"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "MoviesDesignSystem",
            dependencies: ["Kingfisher"]
        ),
        .testTarget(
            name: "MoviesDesignSystemTests",
            dependencies: ["MoviesDesignSystem"]
        )
    ]
)
