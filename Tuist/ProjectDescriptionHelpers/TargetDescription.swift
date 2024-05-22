
import ProjectDescription

let reverseDomain: String = "com.josephgoodrick.projectq"

public protocol SnakeCased {
    var snake_cased: String { get }
}

public protocol TargetDescription: SnakeCased {
    var extendedAppTarget: Self? { get }
    var isTestTarget: Bool { get }
    var sources: SourceFilesList? { get }
    var resources: ResourceFileElements? { get }
    var entitlements: Entitlements? { get }
    var dependencies: [TargetDependency] { get }
    var targetName: String { get }
    var destinations: Destinations { get }
    var product: Product { get }
    var productName: String? { get }
    var bundleId: String { get }
    var deploymentTargets: DeploymentTargets { get }
    var infoPlist: InfoPlist? { get }
    var copyFiles: [CopyFilesAction]? { get }
    var headers: Headers? { get }
    var scripts: [TargetScript] { get }
    var settings: Settings { get }
    var coreDataModels: [CoreDataModel]  { get }
    var environmentVariables: [String : EnvironmentVariable] { get }
    var launchArguments: [LaunchArgument] { get }
    var additionalFiles: [FileElement] { get }
    var buildRules: [BuildRule] { get }
    var mergedBinaryType: MergedBinaryType { get }
    var mergeable: Bool { get }
}

public extension SnakeCased {
    var spaced: String { snake_cased.replacingOccurrences(of: "_", with: " ") }
    var dotted: String { snake_cased.replacingOccurrences(of: "_", with: ".") }
    var dashed: String { snake_cased.replacingOccurrences(of: "_", with: "-") }
    var rawComponents: [String] { snake_cased.components(separatedBy: "_") }
    var allButLastComponent: String { rawComponents.dropLast().joined(separator: "_") }
    var targetName: String { snake_cased }
}

public enum TargetNameComponent: String {
    case App, Kit, Tests, Interfaces, Main, AppExtension, ExtensionKitExtension
}

public extension TargetDescription where Self: RawRepresentable<String> {
    var snake_cased: String { rawValue }
    var components: [TargetNameComponent] { rawComponents.compactMap(TargetNameComponent.init(rawValue:)) }
    var isTestTarget: Bool {
        self.rawComponents.last == TargetNameComponent.Tests.rawValue
    }
    var isApp: Bool {
        components.suffix(2) == [.App, .Main]
    }
    var isAppExtension: Bool {
        components.suffix(1) == [.AppExtension]
    }
    var isExtensionKitExtension: Bool {
        components.suffix(1) == [.ExtensionKitExtension]
    }
    var associatedTestTargetIDDefinedByNaming: Self? {
        guard isTestTarget else { return nil }
        return .init(rawValue: rawComponents.filter({ $0 != TargetNameComponent.Tests.rawValue }).joined(separator: "_"))
    }
    func workspaceBundleID(extending appTarget: TargetDescription? = nil) -> String {
        if let appTarget {
            "\(appTarget.bundleId).\(dashed.lowercased())"
        } else {
            "\(reverseDomain).\(dotted.lowercased())"
        }
    }
    var workspaceDeploymentTargets: DeploymentTargets { .iOS("17.0") }
    var workspaceDestinations: Destinations { .iOS }
    var workspaceProduct: Product {
        switch self {
        case _ where isApp:
            .app
        case _ where isTestTarget:
            .unitTests
        case _ where isAppExtension:
            .appExtension
        case _ where isExtensionKitExtension:
            .extensionKitExtension
        default:
            .framework
        }
    }
    
    var workspaceSources: SourceFilesList? {
        switch self {
        case _ where isTestTarget:
            "\(allButLastComponent)/Tests/**"
        default:
            "\(snake_cased)/Sources/**"
        }
    }
    
    func workspaceResources(privacyManifest: PrivacyManifest? = nil) -> ResourceFileElements? {
        switch self {
        case _ where isApp:
            ResourceFileElements.resources(
                ["\(snake_cased)/Resources/**"],
                privacyManifest: privacyManifest ?? PrivacyManifest.workspaceAppPrivacyManifest
            )
        default:
            .none
        }
    }
    
    func workspaceInfoPlist(with additional: [String : Plist.Value] = [:]) -> InfoPlist? {
        var result: [String : Plist.Value]
        switch self {
        case _ where isApp:
            result = [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "CFBundleDisplayName": "\(spaced)",
                "NSCameraUsageDescription": "If you would like to include photos with your entries, we will need access to your camera to capture them.",
                "UILaunchStoryboardName": "LaunchScreen.storyboard",
                "UIRequiredDeviceCapabilities": [
                    "armv7",
                ],
                "UIRequiresFullScreen": "YES",
                "ITSAppUsesNonExemptEncryption": false,
                "UISupportedInterfaceOrientations": DeviceOrientations.vertical.plistValue,
                "UISupportedInterfaceOrientations~ipad": DeviceOrientations.vertical.plistValue,
            ]
        case _ where isAppExtension:
            result = [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "CFBundleDisplayName": "\(spaced)",
                "ITSAppUsesNonExemptEncryption": false,
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                ],
            ]
        case _ where isExtensionKitExtension:
            result = [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "EXAppExtensionAttributes": [
                    "EXExtensionPointIdentifier": "com.apple.appintents-extension",
                ],
            ]
        default:
            result = [:]
        }

        for (key, value) in additional {
            result[key] = value
        }
        
        return InfoPlist.extendingDefault(
            with: result
        )
    }
    
    var configFilePath: Path? {
        switch self {
        default:
            "\(snake_cased)/Config/Config.xcconfig"
        }
    }

    func workspaceSettings(
        debug: SettingsDictionary = [:],
        release: SettingsDictionary = [:]
    ) -> Settings {
        switch self {
        case _ where isApp || isAppExtension:
            .workspace(
                xcconfigFilePath: configFilePath,
                debug: debug,
                release: release
            )
            .applyToBaseSettings([
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"
            ])
        case _ where isExtensionKitExtension:
            // allows extenionKitExtensions to refer to the same xcconfig as their host app (they need to share the same CFBundleShortVersionString and CFBundleVersion)
            .workspace(xcconfigFilePath: extendedAppTarget?.configFilePath, debug: debug, release: release)
        default:
            .workspace(xcconfigFilePath: .none, debug: debug, release: release)
        }
    }
    
    var workspaceEntitlements: Entitlements? {
        switch self {
        case _ where isApp || isAppExtension:
            "\(snake_cased)/Config/Entitlements.entitlements"
        default:
            .none
        }
    }

}

public typealias DeviceOrientations = Set<DeviceOrientation>

public extension DeviceOrientations {
    static let all: Self = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
    static let vertical: Self = [.portrait, .portraitUpsideDown]
    internal var plistValue: Plist.Value {
        .string(self.map(\.rawValue).sorted().joined(separator: " "))
    }
}

public enum DeviceOrientation: String {
    case portrait = "UIInterfaceOrientationPortrait"
    case portraitUpsideDown = "UIInterfaceOrientationPortraitUpsideDown"
    case landscapeLeft = "UIInterfaceOrientationLandscapeLeft"
    case landscapeRight = "UIInterfaceOrientationLandscapeRight"
}

extension PrivacyManifest {
    public static var workspaceAppPrivacyManifest: PrivacyManifest {
        PrivacyManifest.privacyManifest(
            tracking: false,
            trackingDomains: [],
            collectedDataTypes: [
                [
                    "NSPrivacyCollectedDataType":"NSPrivacyCollectedDataTypeCrashData",
                    "NSPrivacyCollectedDataTypeLinked":false,
                    "NSPrivacyCollectedDataTypeTracking":false,
                    "NSPrivacyCollectedDataTypePurposes": [
                        "NSPrivacyCollectedDataTypePurposeAppFunctionality"
                    ],
                ],
            ],
            accessedApiTypes: [
                [
                    "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
                    "NSPrivacyAccessedAPITypeReasons": [
                        "CA92.1",
                    ],
                ],
            ]
        )
    }
}

public extension Settings {
    static func workspace(
        xcconfigFilePath: Path?,
        debug: SettingsDictionary = [:],
        release: SettingsDictionary = [:],
        defaultSettings: DefaultSettings = .recommended
    ) -> Self {
        Settings.settings(
            base: [
                // module verifier
                "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": "gnu11 gnu++14",
                "ENABLE_MODULE_VERIFIER": "YES",
                // user script sandboxing
                "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
                // generating asset symbol extensions
                "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            ],
            configurations: [
                .debug(name: .debug, settings: debug, xcconfig: xcconfigFilePath),
                .release(name: .release, settings: release, xcconfig: xcconfigFilePath),
            ],
            defaultSettings: defaultSettings
        )
    }
}

public extension Settings {
    func applyToBaseSettings(_ additionalBuildSettings: SettingsDictionary) -> Self {
        var copy = self
        additionalBuildSettings.forEach { (key, value) in
            copy.base[key] = value
        }
        return copy
    }
}

public extension TargetDescription {

    func makeTargetFromDescription() -> Target {
        switch self {
        default:
            Target.target(
                name: targetName,
                destinations: destinations,
                product: product,
                productName: productName,
                bundleId: bundleId,
                deploymentTargets: deploymentTargets,
                infoPlist: infoPlist,
                sources: sources,
                resources: resources,
                copyFiles: copyFiles,
                headers: headers,
                entitlements: entitlements,
                scripts: scripts,
                dependencies: dependencies,
                settings: settings,
                coreDataModels: coreDataModels,
                environmentVariables: environmentVariables,
                launchArguments: launchArguments,
                additionalFiles: additionalFiles,
                buildRules: buildRules,
                mergedBinaryType: mergedBinaryType,
                mergeable: mergeable
            )
        }
    }
    
}
