// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesNetwork",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesNetwork",
            targets: ["MoviesNetwork"]
        )
    ],
    dependencies: [
        .package(path: "../MoviesShared")
    ],
    targets: [
        .target(
            name: "MoviesNetwork",
            dependencies: [.product(name: "SharedModels", package: "MoviesShared")]
        ),
        .testTarget(
            name: "MoviesNetworkTests",
            dependencies: ["MoviesNetwork"]
        )
    ]
)
