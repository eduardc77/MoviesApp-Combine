// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesData",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesData",
            targets: ["MoviesData"]
        )
    ],
    dependencies: [
        .package(path: "../MoviesShared"),
        .package(path: "../MoviesDomain"),
        .package(path: "../MoviesNetwork"),
        .package(path: "../MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesData",
            dependencies: [
                .product(name: "SharedModels", package: "MoviesShared"),
                "MoviesDomain",
                "MoviesNetwork",
                .product(name: "AppLog", package: "MoviesUtilities")
            ]
        ),
        .testTarget(
            name: "MoviesDataTests",
            dependencies: ["MoviesData"]
        )
    ]
)
