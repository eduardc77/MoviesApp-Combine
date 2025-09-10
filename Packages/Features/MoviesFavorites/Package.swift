// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesFavorites",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesFavorites",
            targets: ["MoviesFavorites"]
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
            name: "MoviesFavorites",
            dependencies: [
                "MoviesModels",
                "MoviesNetwork",
                "MoviesPersistence",
                "MoviesDesignSystem",
                "MoviesUtilities"
            ]
        ),
        .testTarget(
            name: "MoviesFavoritesTests",
            dependencies: ["MoviesFavorites"]
        )
    ]
)
