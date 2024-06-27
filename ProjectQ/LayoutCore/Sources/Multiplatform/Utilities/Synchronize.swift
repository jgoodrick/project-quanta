
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
        focusState boolean: FocusState<Bool>.Binding,
        when enumeration: Binding<Value?>,
        equals value: Value,
        onFocusDrop: @escaping () -> Void
    ) -> some View {
        self
            .onChange(of: enumeration.wrappedValue) { _, newEnumValue in
                if let newEnumValue {
                    if newEnumValue == value {
                        boolean.wrappedValue = true
                    }
                } else if boolean.wrappedValue {
                    boolean.wrappedValue = false
                }
            }
            .onChange(of: boolean.wrappedValue) { _, isNowFocused in
                if isNowFocused {
                    enumeration.wrappedValue = value
                } else if enumeration.wrappedValue == value {
                    enumeration.wrappedValue = nil
                    onFocusDrop()
                }
            }
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
