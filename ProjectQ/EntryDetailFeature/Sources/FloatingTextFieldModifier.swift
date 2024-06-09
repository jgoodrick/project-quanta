
import ComposableArchitecture
import FeatureCore
import LayoutCore
import SwiftUI

struct FloatingTextFieldInset: ViewModifier {
    
    let store: StoreOf<FloatingTextField>
    let placeholder: String
    var autocapitalization: Autocapitalization = .none

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if !store.collapsed {
                    FloatingTextFieldView(
                        store: store,
                        placeholder: placeholder
                    )
                    .padding()
                    .transformEnvironment(\.floatingTextField) {
                        $0.autocapitalization = autocapitalization
                    }
                }
            }
    }
}
