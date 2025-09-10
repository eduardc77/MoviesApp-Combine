// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesDetails",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesDetails",
            targets: ["MoviesDetails"]
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
            name: "MoviesDetails",
            dependencies: [
                "MoviesModels",
                "MoviesNetwork",
                "MoviesPersistence",
                "MoviesDesignSystem",
                "MoviesUtilities"
            ]
        ),
        .testTarget(
            name: "MoviesDetailsTests",
            dependencies: ["MoviesDetails"]
        )
    ]
)
