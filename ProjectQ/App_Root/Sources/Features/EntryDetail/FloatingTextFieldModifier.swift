
import ComposableArchitecture
import SwiftUI

struct FloatingTextFieldInset: ViewModifier {
    
    let store: StoreOf<FloatingTextField>
    let placeholder: String
    var autocapitalization: UITextAutocapitalizationType = .none
    var entryStyle: FloatingTextFieldView.Style.EntryStyle = .field

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
                        $0.entryStyle = entryStyle
                    }
                }
            }
    }
}
