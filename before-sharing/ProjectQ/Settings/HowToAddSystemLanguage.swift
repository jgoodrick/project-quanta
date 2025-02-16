
import AppModel
import ComposableArchitecture
import Foundation
import LayoutCore
import StructuralModel
import SwiftUI

@Reducer
struct HowToAddSystemLanguage {
    @ObservableState
    struct State: Equatable {
        @Shared(.model) var model
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            }
        }
    }
}

struct HowToAddSystemLanguageView: View {

    @Bindable var store: StoreOf<HowToAddSystemLanguage>

    @Environment(\.locale) var locale

    var body: some View {
        VStack {
            Spacer()
            Text(
            """
            To add a system language, go to
            
            Settings > General > Keyboard > Keyboards

            then tap 'Add New Keyboard' and select the language you want to add
            """
            )
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
        #if os(tvOS)
        .textFieldStyle(.automatic)
        #elseif !os(watchOS)
        .textFieldStyle(.roundedBorder)
        #endif
    }
}

#Preview { Preview }
private var Preview: some View {
    HowToAddSystemLanguageView(store: .init(initialState: .init(), reducer: { HowToAddSystemLanguage() }))
}
