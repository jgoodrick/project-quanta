// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "QDBCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "QDBCore",
            targets: ["QDBCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/sqlite-data", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-navigation", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-structured-queries", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", branch: "main"),
    ],
    targets: [
        .target(
            name: "QDBCore",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "SwiftUINavigation", package: "swift-navigation"),
                .product(name: "SQLiteData", package: "sqlite-data"),
                .product(name: "StructuredQueries", package: "swift-structured-queries"),
                .product(name: "StructuredQueriesSQLite", package: "swift-structured-queries"),
            ]),
        .testTarget(
            name: "QDBCoreTests",
            dependencies: [
                "QDBCore",
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "StructuredQueriesTestSupport", package: "swift-structured-queries"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-warn-long-function-bodies=50",
                    "-Xfrontend",
                    "-warn-long-expression-type-checking=50",
                ])
            ]
        ),
    ]
)
