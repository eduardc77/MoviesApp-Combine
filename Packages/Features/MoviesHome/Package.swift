// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesHome",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesHome",
            targets: ["MoviesHome"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/MoviesDomain"),
        .package(path: "../../Core/MoviesShared"),
        .package(path: "../../Core/MoviesData"),
        .package(path: "../../Core/MoviesNavigation"),
        .package(path: "../../Core/MoviesDesignSystem"),
        .package(path: "../../Core/MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesHome",
            dependencies: [
                .product(name: "SharedModels", package: "MoviesShared"),
                "MoviesDomain",
                "MoviesData",
                "MoviesNavigation",
                "MoviesDesignSystem",
                .product(name: "AppLog", package: "MoviesUtilities")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MoviesHomeTests",
            dependencies: ["MoviesHome"]
        )
    ]
)
