
import SwiftUI

extension View {
    public func synchronize<Value: Equatable>(
        _ lhs: Binding<Value>,
        _ rhs: Binding<Value>
    ) -> some View {
        self
            .onChange(of: lhs.wrappedValue) { _, new in rhs.wrappedValue = new }
            .onChange(of: rhs.wrappedValue) { _, new in lhs.wrappedValue = new }
    }
}

extension View {
    public func synchronize<Value: Equatable>(
        focusState lhs: FocusState<Value>.Binding,
        with rhs: Binding<Value>
    ) -> some View {
        self
            .onChange(of: rhs.wrappedValue) { _, new in lhs.wrappedValue = new }
            .onChange(of: lhs.wrappedValue) { _, new in rhs.wrappedValue = new }
    }
}

extension View {
    public func synchronize<Value: Equatable>(
        optional lhs: Binding<Value>?,
        with rhs: Binding<Value>,
        fallback: Value
    ) -> some View {
        self
            .onChange(of: rhs.wrappedValue) { _, new in lhs?.wrappedValue = new }
            .onChange(of: lhs?.wrappedValue) { _, new in rhs.wrappedValue = new ?? fallback }
    }
}
