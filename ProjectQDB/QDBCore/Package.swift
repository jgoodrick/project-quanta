// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "QDBCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14),
        .tvOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: Name.CoreApp,
            targets: [Name.CoreApp]
        ),
        .library(
            name: Name.CoreDB,
            targets: [Name.CoreDB]
        ),
        .library(
            name: Name.CoreUI,
            targets: [Name.CoreUI]
        ),
        .library(
            name: Name.UIComponents,
            targets: [Name.UIComponents]
        ),
    ],
    dependencies: [
        .Dependencies,
        .SQLiteData,
    ],
    targets: [
        .target(
            name: Name.CoreApp,
            dependencies: [
                .CoreDB,
                .CoreUI,
                .SQLiteData,
            ]
        ),
        .target(
            name: Name.CoreDB,
            dependencies: [
                .SQLiteData,
            ]
        ),
        .testTarget(
            name: Name.CoreDBTests,
            dependencies: [
                .CoreDB,
                .DependenciesDataTestSupport,
                .SQLiteDataTestSupport,
            ]
        ),
        .target(
            name: Name.CoreUI,
            dependencies: [
                .UIComponents,
                .SQLiteData,
            ]
        ),
        .target(
            name: Name.UIComponents,
            dependencies: []
        ),
    ]
)

extension Package.Dependency {
    static var Dependencies: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
    }
    static var SQLiteData: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.0.0")
    }
}

enum Name {
    static var CoreApp: String { "CoreApp" }
    static var CoreUI: String { "CoreUI" }
    static var CoreDB: String { "CoreDB" }
    static var CoreDBTests: String { "CoreDBTests" }
    static var UIComponents: String { "UIComponents" }
}

extension Target.Dependency {
    static var CoreDB: Target.Dependency { .byNameItem(name: Name.CoreDB, condition: .none) }
    static var CoreUI: Target.Dependency { .byNameItem(name: Name.CoreUI, condition: .none) }
    static var UIComponents: Target.Dependency { .byNameItem(name: Name.UIComponents, condition: .none) }
    static var SQLiteData: Target.Dependency { .product(name: "SQLiteData", package: "sqlite-data") }
    static var SQLiteDataTestSupport: Target.Dependency { .product(name: "SQLiteDataTestSupport", package: "sqlite-data") }
    static var DependenciesDataTestSupport: Target.Dependency { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
}
