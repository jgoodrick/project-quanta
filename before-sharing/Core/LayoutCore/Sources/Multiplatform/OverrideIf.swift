
import SwiftUI

struct OverrideIf<T>: ViewModifier {
    init(_ condition: Bool, _ keyPath: WritableKeyPath<EnvironmentValues, T>, _ value: T) {
        self.condition = condition
        self.keyPath = keyPath
        self.value = value
    }
    
    let condition: Bool
    let keyPath: WritableKeyPath<EnvironmentValues, T>
    let value: T
    func body(content: Content) -> some View {
        if condition {
            content
                .environment(keyPath, value)
        } else {
            content
        }
    }
}

