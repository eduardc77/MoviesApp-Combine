// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesModels",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesModels",
            targets: ["MoviesModels"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoviesModels",
            dependencies: []
        ),
        .testTarget(
            name: "MoviesModelsTests",
            dependencies: ["MoviesModels"]
        )
    ]
)
