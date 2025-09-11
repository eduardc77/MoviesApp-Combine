// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoviesDomain",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "MoviesDomain",
            targets: ["MoviesDomain"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MoviesDomain",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MoviesDomainTests",
            dependencies: ["MoviesDomain"]
        ),
    ]
)
