// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesSearch",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesSearch",
            targets: ["MoviesSearch"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/MoviesDomain"),
        .package(path: "../../Core/MoviesNetwork"),
        .package(path: "../../Core/MoviesPersistence"),
        .package(path: "../../Core/MoviesNavigation"),
        .package(path: "../../Core/MoviesDesignSystem"),
        .package(path: "../../Core/MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesSearch",
            dependencies: [
                "MoviesDomain",
                "MoviesNetwork",
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
            name: "MoviesSearchTests",
            dependencies: ["MoviesSearch"]
        )
    ]
)
