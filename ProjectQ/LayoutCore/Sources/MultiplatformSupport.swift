
import SwiftUI

public struct InlineNavigationBar_iOS: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
        #else
        content
        #endif
    }
}
