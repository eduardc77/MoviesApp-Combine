// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesSearch",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesSearch",
            targets: ["MoviesSearch"]
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
            name: "MoviesSearch",
            dependencies: [
                "MoviesModels",
                "MoviesNetwork",
                "MoviesPersistence",
                "MoviesDesignSystem",
                "MoviesUtilities"
            ]
        ),
        .testTarget(
            name: "MoviesSearchTests",
            dependencies: ["MoviesSearch"]
        )
    ]
)
