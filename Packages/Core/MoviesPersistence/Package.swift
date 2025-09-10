// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesPersistence",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoviesPersistence",
            targets: ["MoviesPersistence"]
        )
    ],
    dependencies: [
        .package(path: "../MoviesModels"),
        .package(path: "../MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesPersistence",
            dependencies: ["MoviesModels", "MoviesUtilities"]
        ),
        .testTarget(
            name: "MoviesPersistenceTests",
            dependencies: ["MoviesPersistence"]
        )
    ]
)
