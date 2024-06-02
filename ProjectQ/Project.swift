
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = Project.init(
    name: "ProjectQ",
    targets: TargetID.allCases.map({ $0.makeTargetFromDescription() })
)

enum TargetID: String, CaseIterable {
    
    case App_Main
    case App_Main_Tests
    case App_Root
    case App_Root_Tests
//    case Intent_ExtensionKitExtension
    case Model
    case Model_Tests
//    case Widget_AppExtension

}

extension TargetDependency {
    static func target(_ id: TargetID) -> Self {
        .target(name: id.targetName, condition: .none)
    }
}

extension TargetID: TargetDescription {
    var dependencies: [TargetDependency] {
        switch self {
        case .App_Main:
            return [
                .target(.App_Root),
//                .target(.Intent_ExtensionKitExtension),
//                .target(.Widget_AppExtension),
            ]
        case .App_Main_Tests:
            return [
                .target(.App_Main),
            ]
        case .App_Root:
            return [
                .target(.Model),
            ]
        case .App_Root_Tests:
            return [
                .target(.App_Root),
            ]
//        case .Intent_ExtensionKitExtension:
//            return [
//                .target(.Model),
//            ]
        case .Model:
            return [
                .external(name: "ComposableArchitecture", condition: .none),
            ]
        case .Model_Tests:
            return [
                .target(.Model),
            ]
//        case .Widget_AppExtension:
//            return [
//                .target(.Model),
//            ]
        }
    }

    var bundleId: String {
        switch self {
        case _ where isAppExtension || isExtensionKitExtension:
            workspaceBundleID(extending: TargetID.App_Main)
        default:
            workspaceBundleID()
        }
    }
    
    var settings: Settings {
        switch self {
        default:
            workspaceSettings()
        }
    }
        
    var infoPlist: InfoPlist? {
        switch self {
        case .App_Main:
            workspaceInfoPlist(
                with: [
                    "CFBundleDisplayName": "ProjectQ",
                ]
            )
        default:
            workspaceInfoPlist()
        }
    }
    
    var extendedAppTarget: TargetID? {
        switch self {
        case _ where isExtensionKitExtension:
            .App_Main
        default:
            .none
        }
    }
    
    var destinations: Destinations {
        switch self {
        default: workspaceDestinations
        }
    }

    var sources: SourceFilesList? { workspaceSources }
    var resources: ResourceFileElements? { workspaceResources() }
    var entitlements: Entitlements? { workspaceEntitlements }
    var product: Product { workspaceProduct }
    var productName: String? { snake_cased }
    var deploymentTargets: DeploymentTargets { workspaceDeploymentTargets }
    var copyFiles: [CopyFilesAction]? { .none }
    var headers: Headers? { .none }
    var scripts: [TargetScript] { [] }
    var coreDataModels: [CoreDataModel]  { [] }
    var environmentVariables: [String : EnvironmentVariable] { [:] }
    var launchArguments: [LaunchArgument] { [] }
    var additionalFiles: [FileElement] { [] }
    var buildRules: [BuildRule] { [] }
    var mergedBinaryType: MergedBinaryType { .disabled }
    var mergeable: Bool { false }

}

