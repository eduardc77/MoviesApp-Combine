// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MoviesNavigation",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "MoviesNavigation",
            targets: ["MoviesNavigation"]
        ),
    ],
    dependencies: [
        .package(path: "../MoviesDomain")
    ],
    targets: [
        .target(
            name: "MoviesNavigation",
            dependencies: ["MoviesDomain"]
        ),
        .testTarget(
            name: "MoviesNavigationTests",
            dependencies: ["MoviesNavigation"]
        ),
    ]
)
