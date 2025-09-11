// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesPersistence",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "MoviesPersistence",
            targets: ["MoviesPersistence"]
        )
    ],
    dependencies: [
        .package(path: "../MoviesDomain"),
        .package(path: "../MoviesUtilities")
    ],
    targets: [
        .target(
            name: "MoviesPersistence",
            dependencies: ["MoviesDomain", "MoviesUtilities"]
        ),
        .testTarget(
            name: "MoviesPersistenceTests",
            dependencies: ["MoviesPersistence"]
        )
    ]
)
