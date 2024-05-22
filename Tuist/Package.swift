// swift-tools-version: 5.9

import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
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

