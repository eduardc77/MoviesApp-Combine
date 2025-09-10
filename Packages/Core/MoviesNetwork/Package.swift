// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesNetwork",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesNetwork",
            targets: ["MoviesNetwork"]
        )
    ],
    dependencies: [
        .package(path: "../MoviesModels")
    ],
    targets: [
        .target(
            name: "MoviesNetwork",
            dependencies: ["MoviesModels"]
        ),
        .testTarget(
            name: "MoviesNetworkTests",
            dependencies: ["MoviesNetwork"]
        )
    ]
)
