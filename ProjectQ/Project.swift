
import ProjectDescription
import ProjectDescriptionHelpers

let reverseDomain: String = "com.josephgoodrick.projectq"

enum TargetID: String, CaseIterable, SnakeCased {
    
    var snake_cased: String { rawValue }
    
    case ProjectQ_iOS
    case Layout_Core
    
    case Multiplatform_Core
    case Multiplatform_Core_Tests

    case App_Model
    case App_Model_Tests
    case Relational_Model
    case Relational_Model_Tests
    case Structural_Model

}

let project: Project = Project.init(
    name: "ProjectQ",
    targets: TargetID.allCases.map({
        switch $0 {
        default:
            Target.target(
                name: $0.targetName,
                destinations: $0.destinations,
                product: $0.product,
                productName: $0.productName,
                bundleId: $0.bundleId,
                deploymentTargets: $0.deploymentTargets,
                infoPlist: $0.infoPlist,
                sources: $0.sources,
                resources: $0.resources,
                entitlements: $0.entitlements,
                dependencies: $0.dependencies,
                settings: $0.settings,
                additionalFiles: $0.additionalFiles
            )
        }
    })
)

extension TargetDependency {
    static func target(_ id: TargetID) -> Self {
        .target(name: id.targetName, condition: .none)
    }
}

extension TargetID {
    var dependencies: [TargetDependency] {
        switch self {
        case .App_Model:
            return [
                .external(name: "ComposableArchitecture", condition: .none),
                .target(.Relational_Model),
            ]
        case .App_Model_Tests:
            return [ .target(.App_Model) ]
        case .Multiplatform_Core:
            return [
                .target(.App_Model),
                .target(.Structural_Model),
                .target(.Layout_Core),
            ]
        case .Multiplatform_Core_Tests:
            return [ .target(.Multiplatform_Core) ]
        case .Layout_Core:
            return [
                .target(.Structural_Model),
            ]
        case .ProjectQ_iOS:
            return [
                .target(.Multiplatform_Core),
            ]
        case .Relational_Model:
            return [
                .target(.Structural_Model),
            ]
        case .Relational_Model_Tests:
            return [ .target(.Relational_Model) ]
        case .Structural_Model:
            return [
                // pure data structures
            ]
        }
    }

    var bundleId: String {
        switch self {
//        case _ where isAppExtension || isExtensionKitExtension:
//            "\(TargetID.ProjectQ_iOS.bundleId).\(dashed.lowercased())"
        default:
            "\(reverseDomain).\(dotted.lowercased())"
        }
    }
    
    var settings: Settings {
        switch self {
        case _ where isApp:
            let result = Settings.settings(
                base: [
                    // module verifier
                    "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": "gnu11 gnu++14",
                    "ENABLE_MODULE_VERIFIER": "YES",
                    // user script sandboxing
                    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
                    // generating asset symbol extensions
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    // asset color
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"
                ],
                configurations: [
                    .debug(
                        name: .debug,
                        settings: [:],
                        xcconfig: "\(relativeRootPath)/Config/Config.xcconfig"
                    ),
                    .release(
                        name: .release,
                        settings: [:], 
                        xcconfig: "\(relativeRootPath)/Config/Config.xcconfig"
                    ),
                ],
                defaultSettings: .recommended
            )
//            if case .ProjectQ_tvOS = self {
//                result.base["ASSETCATALOG_COMPILER_APPICON_NAME"] = "Brand Assets"
//            }
            return result
        default:
            return Settings.settings()
        }
    }
        
    var infoPlist: InfoPlist? {
        var result: [String : Plist.Value] = [
            "CFBundleShortVersionString": "$(MARKETING_VERSION)",
            "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        ]
        
        let additional: [String: Plist.Value]
        switch self {
        case .ProjectQ_iOS:
            additional = [
                "CFBundleDisplayName": "Project Q",
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
            additional = [
                "CFBundleDisplayName": "\(spaced)",
                "ITSAppUsesNonExemptEncryption": false,
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                ],
            ]
        case _ where isExtensionKitExtension:
            additional = [
                "EXAppExtensionAttributes": [
                    "EXExtensionPointIdentifier": "com.apple.appintents-extension",
                ],
            ]
        default:
            additional = [
                "CFBundleDisplayName": "\(spaced)",
            ]
        }

        for (key, value) in additional {
            result[key] = value
        }
        
        return InfoPlist.extendingDefault(
            with: result
        )
    }
    
    var destinations: Destinations {
        switch self {
        case .ProjectQ_iOS: [.iPhone, .iPad]
//        case .ProjectQ_macOS: [.mac]
//        case .ProjectQ_tvOS: [.appleTv]
//        case .ProjectQ_watchOS: [.appleWatch]
        default:
            [.iPhone, .iPad, .mac, .appleWatch, .appleTv]
        }
    }
    
    var relativeRootPath: String {
        if let associatedTestTargetIDDefinedByNaming {
            associatedTestTargetIDDefinedByNaming.relativeRootPath
        } else if isApp {
            compactedExceptLast
        } else {
            compacted
        }
    }

    var sources: SourceFilesList? {
        switch self {
        case _ where isTestTarget:
            "\(relativeRootPath)/Tests/**"
        default:
            "\(relativeRootPath)/Sources/**"
        }
    }
    
    var additionalFiles: [FileElement] {
        switch self {
        case .ProjectQ_iOS:
            [
                "\(relativeRootPath)/Documentation/**"
            ]
        default: []
        }
    }
    
    var resources: ResourceFileElements? {
        switch self {
        case _ where isApp:
            ResourceFileElements.resources(
                ["\(relativeRootPath)/Resources/**"],
                privacyManifest: PrivacyManifest.appPrivacyManifest
            )
        default:
            .none
        }
    }
    
    var entitlements: Entitlements? {
        switch self {
        case _ where isApp || isAppExtension:
            "\(relativeRootPath)/Config/Entitlements.entitlements"
        default:
            .none
        }
    }

    var product: Product {
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
    
    var targetName: String {
        switch self {
        case _ where isApp:
            compactedExceptLast
        default:
            compacted
        }
    }

    var productName: String? {
        switch self {
        case _ where isApp:
            compactedExceptLast
        default:
            compacted
        }
    }
    
    var deploymentTargets: DeploymentTargets {
        switch self {
        case .ProjectQ_iOS:
            .iOS("17.0")
//        case .ProjectQ_macOS:
//            .macOS("14.0")
//        case .ProjectQ_tvOS:
//            .tvOS("17.0")
//        case .ProjectQ_watchOS:
//            .watchOS("10.0")
        default:
            .multiplatform(iOS: "17.0", macOS: "14.0", watchOS: "10.0", tvOS: "17.0")
        }
    }

}

protocol SnakeCased {
    var snake_cased: String { get }
}

extension SnakeCased {
    var compacted: String { snake_cased.replacingOccurrences(of: "_", with: "") }
    var spaced: String { snake_cased.replacingOccurrences(of: "_", with: " ") }
    var dotted: String { snake_cased.replacingOccurrences(of: "_", with: ".") }
    var dashed: String { snake_cased.replacingOccurrences(of: "_", with: "-") }
    var rawComponents: [String] { snake_cased.components(separatedBy: "_") }
    var allButLastRawComponent: String { rawComponents.dropLast().joined(separator: "_") }
    var compactedExceptLast: String {
        rawComponents.last.map({ "\(rawComponents.dropLast().joined())_\($0)" }) ?? compacted
    }
}

enum TargetNameComponent: String {
    case App, Kit, Tests, Interfaces, Main, AppExtension, ExtensionKitExtension
}

extension TargetID {
    var components: [TargetNameComponent] {
        rawComponents.compactMap(TargetNameComponent.init(rawValue:))
    }
    var isApp: Bool {
        switch self {
        case .ProjectQ_iOS: true
        default: false
        }
    }
    var isTestTarget: Bool {
        self.rawComponents.last == TargetNameComponent.Tests.rawValue
    }
    var isAppExtension: Bool {
        components.suffix(1) == [.AppExtension]
    }
    var isExtensionKitExtension: Bool {
        components.suffix(1) == [.ExtensionKitExtension]
    }
    var associatedTestTargetIDDefinedByNaming: Self? {
        guard isTestTarget else { return nil }
        return .init(rawValue: rawComponents.filter({ 
            $0 != TargetNameComponent.Tests.rawValue
        }).joined(separator: "_"))
    }
        
}

extension PrivacyManifest {
    static var appPrivacyManifest: PrivacyManifest {
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

