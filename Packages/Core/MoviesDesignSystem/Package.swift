// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesDesignSystem",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesDesignSystem",
            targets: ["MoviesDesignSystem"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(path: "../MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesDesignSystem",
            dependencies: ["Kingfisher", "MoviesUtilities"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
