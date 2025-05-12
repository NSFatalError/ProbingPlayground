// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]
        ),
        .library(
            name: "ModuleB",
            targets: ["ModuleB"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/NSFatalError/Probing",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: [
                .product(name: "Probing", package: "Probing")
            ]
        ),
        .testTarget(
            name: "ModuleATests",
            dependencies: [
                "ModuleA",
                .product(name: "ProbeTesting", package: "Probing")
            ]
        ),
        .target(
            name: "ModuleB",
            dependencies: [
                "ModuleA",
                .product(name: "Probing", package: "Probing")
            ]
        ),
        .testTarget(
            name: "ModuleBTests",
            dependencies: [
                "ModuleB",
                .product(name: "ProbeTesting", package: "Probing")
            ]
        )
    ]
)
