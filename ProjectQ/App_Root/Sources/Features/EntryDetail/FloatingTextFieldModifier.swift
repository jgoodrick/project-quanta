
import ComposableArchitecture
import SwiftUI

struct FloatingTextFieldInset: ViewModifier {
    
    let store: StoreOf<FloatingTextField>
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if !store.collapsed {
                    FloatingTextFieldView(
                        store: store
                    )
                    .padding()
                }
            }
    }
}

struct LanguageTrackingFloatingTextFieldInset: ViewModifier {
    
    let store: StoreOf<LanguageTrackingFloatingTextField>
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if !store.textField.collapsed {
                    LanguageTrackingFloatingTextFieldView(
                        store: store
                    )
                    .padding()
                }
            }
    }
}

