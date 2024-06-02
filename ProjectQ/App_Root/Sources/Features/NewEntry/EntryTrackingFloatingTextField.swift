

import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct LanguageTrackingFloatingTextField {
    
    @ObservableState
    public struct State: Equatable {
        @Shared var languageID: Language.ID?
        var textField: FloatingTextField.State = .init()
    }
    
    public enum Action {
        case textField(FloatingTextField.Action)
        
        case task
        case languageIDUpdated(Language.ID?)
    }
    
    public var body: some Reducer<State, Action> {
        
        Scope(state: \.textField, action: \.textField) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .textField: return .none
            case .task:
                state.textField.languageOverride = state.languageID
                return .publisher {
                    state.$languageID.publisher.map(Action.languageIDUpdated)
                }
            case .languageIDUpdated(let newID):
                
                state.textField.languageOverride = newID
                
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
