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
            name: "MoviesLogging",
            targets: ["MoviesLogging"]
        ),
        .library(
            name: "DateUtilities",
            targets: ["DateUtilities"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoviesLogging",
            path: "Sources/MoviesLogging"
        ),
        .target(
            name: "DateUtilities",
            path: "Sources/DateUtilities"
        ),
        .testTarget(
            name: "DateUtilitiesTests",
            dependencies: ["DateUtilities"]
        ),
    ]
)
