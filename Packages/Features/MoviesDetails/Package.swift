// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesDetails",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesDetails",
            targets: ["MoviesDetails"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/MoviesDomain"),
        .package(path: "../../Core/MoviesNetwork"),
        .package(path: "../../Core/MoviesPersistence"),
        .package(path: "../../Core/MoviesDesignSystem"),
        .package(path: "../../Core/MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesDetails",
            dependencies: [
                "MoviesDomain",
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
