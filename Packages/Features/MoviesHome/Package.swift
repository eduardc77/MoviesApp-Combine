// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesHome",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesHome",
            targets: ["MoviesHome"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/MoviesModels"),
        .package(path: "../../Core/MoviesNetwork"),
        .package(path: "../../Core/MoviesPersistence"),
        .package(path: "../../Core/MoviesDesignSystem"),
        .package(path: "../../Core/MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesHome",
            dependencies: [
                "MoviesModels",
                "MoviesNetwork",
                "MoviesPersistence",
                "MoviesDesignSystem",
                "MoviesUtilities"
            ]
        ),
        .testTarget(
            name: "MoviesHomeTests",
            dependencies: ["MoviesHome"]
        )
    ]
)
