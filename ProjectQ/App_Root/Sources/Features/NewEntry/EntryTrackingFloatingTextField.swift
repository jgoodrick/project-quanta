

import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct LanguageTrackingFloatingTextField {
    
    @ObservableState
    public struct State: Equatable {
        @Shared var languages: [Language.ID]
        var textField: FloatingTextField.State = .init()
    }
    
    public enum Action {
        case textField(FloatingTextField.Action)
        
        case task
        case languagesUpdated([Language.ID])
    }
    
    public var body: some Reducer<State, Action> {
        
        Scope(state: \.textField, action: \.textField) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .textField: return .none
            case .task:
                state.textField.languageOverride = state.languages.first
                return .publisher {
                    state.$languages.publisher.map(Action.languagesUpdated)
                }
            case .languagesUpdated(let newIDs):
                
                state.textField.languageOverride = newIDs.first
                
                return .none
            }
        }
    }
}

public struct LanguageTrackingFloatingTextFieldView: View {
    
    var store: StoreOf<LanguageTrackingFloatingTextField>
    
    public var body: some View {
        FloatingTextFieldView(store: store.scope(state: \.textField, action: \.textField))
            .task { await store.send(.task).finish() }
    }
}
