
import ProjectDescription

public typealias DeviceOrientations = Set<DeviceOrientation>

extension DeviceOrientations {
    public static let all: Self = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
    public static let vertical: Self = [.portrait, .portraitUpsideDown]
    public var plistValue: Plist.Value {
        .string(self.map(\.rawValue).sorted().joined(separator: " "))
    }
}

public enum DeviceOrientation: String {
    case portrait = "UIInterfaceOrientationPortrait"
    case portraitUpsideDown = "UIInterfaceOrientationPortraitUpsideDown"
    case landscapeLeft = "UIInterfaceOrientationLandscapeLeft"
    case landscapeRight = "UIInterfaceOrientationLandscapeRight"
}

