
import ComposableArchitecture
import FeatureCore
import LayoutCore
import SwiftUI

struct ToolbarTextFieldInset: ViewModifier {
    
    let store: StoreOf<ToolbarTextField>
    let placeholder: String
    var autocapitalization: Autocapitalization = .none

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if !store.collapsed {
                    ToolbarTextFieldView(
                        store: store,
                        placeholder: placeholder
                    )
                    .padding()
                    .transformEnvironment(\.toolbarTextField) {
                        $0.autocapitalization = autocapitalization
                    }
                }
            }
    }
}
