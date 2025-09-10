// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesUtilities",
    platforms: [
        .iOS(.v17)
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
