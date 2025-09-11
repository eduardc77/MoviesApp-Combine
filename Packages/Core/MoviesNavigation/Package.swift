// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            dependencies: ["MoviesDomain"],
            path: "Sources/MoviesNavigation"
        ),
        .testTarget(
            name: "MoviesNavigationTests",
            dependencies: ["MoviesNavigation"],
            path: "Tests/MoviesNavigationTests"
        ),
    ]
)
