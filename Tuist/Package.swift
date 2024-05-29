// swift-tools-version: 5.9

import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
            "Dependencies": .framework,
            "Clocks": .framework,
            "ConcurrencyExtras": .framework,
            "CombineSchedulers": .framework,
            "IdentifiedCollections": .framework,
            "OrderedCollections": .framework,
            "_CollectionsUtilities": .framework,
            "DependenciesMacros": .framework,
            "SwiftUINavigationCore": .framework,
            "Perception": .framework,
            "CasePaths": .framework,
            "CustomDump": .framework,
            "XCTestDynamicOverlay": .framework,
        ]
    )
#endif

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.1"),
    ]
)

