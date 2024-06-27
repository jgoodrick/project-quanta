
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
        equals value: Value
    ) -> some View {
        self
            .onChange(of: enumeration.wrappedValue) { _, newEnumValue in
                print("driving the focus state to \(newEnumValue == value)")
                boolean.wrappedValue = newEnumValue == value
            }
            .onChange(of: boolean.wrappedValue) { wasTrue, isTrue in
                switch (wasTrue, isTrue) {
                case (false, true):
                    print("setting focus state to \(value)")
                    enumeration.wrappedValue = value
                case (true, false): 
                    print("removing focus from \(value)")
                    enumeration.wrappedValue = .none
                case (true, true), (false, false):
                    print("focus state was changed to matching value")
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
