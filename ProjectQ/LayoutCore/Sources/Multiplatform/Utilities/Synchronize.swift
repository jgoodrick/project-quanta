
import SwiftUI

extension View {
    public func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { _, new in second.wrappedValue = new }
            .onChange(of: second.wrappedValue) { _, new in first.wrappedValue = new }
    }
}

