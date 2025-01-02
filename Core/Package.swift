// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v18),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "AppModel",
            targets: ["AppModel"]),
        .library(
            name: "LayoutCore",
            targets: ["LayoutCore"]),
        .library(
            name: "MultiplatformCore",
            targets: ["MultiplatformCore"]),
        .library(
            name: "RelationalModel",
            targets: ["RelationalModel"]),
        .library(
            name: "StructuralModel",
            targets: ["StructuralModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "main"),
    ],
    targets: [
        .target(
            name: "AppModel",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                "RelationalModel",
            ],
            path: "AppModel/Sources"),
        .target(
            name: "LayoutCore",
            dependencies: ["StructuralModel"],
            path: "LayoutCore/Sources"),
        .target(
            name: "MultiplatformCore",
            dependencies: ["AppModel", "LayoutCore", "StructuralModel"],
            path: "MultiplatformCore/Sources"),
        .target(
            name: "RelationalModel",
            dependencies: ["StructuralModel"],
            path: "RelationalModel/Sources"),
        .target(
            name: "StructuralModel",
            dependencies: [],
            path: "StructuralModel/Sources"),

        // Test Targets

        .testTarget(
            name: "AppModelTests",
            dependencies: ["AppModel"],
            path: "AppModel/Tests"),
        .testTarget(
            name: "LayoutCoreTests",
            dependencies: ["LayoutCore"],
            path: "LayoutCore/Tests"),
        .testTarget(
            name: "MultiplatformCoreTests",
            dependencies: ["MultiplatformCore"],
            path: "MultiplatformCore/Tests"),
        .testTarget(
            name: "RelationalModelTests",
            dependencies: ["RelationalModel"],
            path: "RelationalModel/Tests"),
        .testTarget(
            name: "StructuralModelTests",
            dependencies: ["StructuralModel"],
            path: "StructuralModel/Tests"),
    ]
)
