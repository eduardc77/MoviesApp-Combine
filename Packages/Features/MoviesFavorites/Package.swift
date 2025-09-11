// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesFavorites",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesFavorites",
            targets: ["MoviesFavorites"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/MoviesDomain"),
        .package(path: "../../Core/MoviesPersistence"),
        .package(path: "../../Core/MoviesNavigation"),
        .package(path: "../../Core/MoviesDesignSystem"),
        .package(path: "../../Core/MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesFavorites",
            dependencies: [
                "MoviesDomain",
                "MoviesPersistence",
                "MoviesNavigation",
                "MoviesDesignSystem",
                "MoviesUtilities"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MoviesFavoritesTests",
            dependencies: ["MoviesFavorites"]
        )
    ]
)
