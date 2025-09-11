// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesUtilities",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesUtilities",
            targets: ["MoviesUtilities"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoviesUtilities",
            dependencies: []
        ),
        .testTarget(
            name: "MoviesUtilitiesTests",
            dependencies: ["MoviesUtilities"]
        )
    ]
)
