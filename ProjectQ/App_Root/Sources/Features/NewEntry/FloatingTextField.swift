
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct FloatingTextField {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        var matching: TranslatableEntity?
        var languageOverride: Language.ID?
        var text: String = ""
        var collapsed: Bool = true
        
        var overriddenLanguage: Language.ID? {
            languageOverride ?? matching.flatMap({ db.keyboardLanguageID(for: $0) })
        }
        var language: Language {
            overriddenLanguage.flatMap({ $db[language: $0]?.shared.wrappedValue }) ?? settings.focusedLanguage
        }
        
        mutating func reset() {
            text = ""
            collapsed = true
        }
        
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case rotatingButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case fieldCommitted
            case saveEntryButtonTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding, .delegate: return .none
                
            case .rotatingButtonTapped:
                
                if !state.collapsed {
                    state.reset()
                } else {
                    state.collapsed = false
                }
                
                return .none
                
            }
        }
    }
}

public struct FloatingTextFieldView: View {
    
    @SwiftUI.Bindable var store: StoreOf<FloatingTextField>
    let placeholder: String

    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
        var customHeight: Double? = .none
        var font: Font = .title2
        var background: Color = .gray
        var autocapitalization: UITextAutocapitalizationType = .none
        var autocorrectionDisabled: Bool = true
        var implementation: Implementation = .uiKit
        enum Implementation {
            case uiKit
            case swiftUI
        }
        var entryStyle: EntryStyle = .field
        enum EntryStyle {
            case field
            case editor
        }
    }
    
    @Environment(\.floatingTextField) var style

    public var body: some View {
        GeometryReader { proxy in
            
            ZStack(alignment: .trailing) {
                
                Capsule()
                    .fill(.background)
                
                HStack(spacing: 0) {
                    Group {
                        switch style.implementation {
                        case .uiKit:
                            Group {
                                switch style.entryStyle {
                                case .field:
                                    ConfigurableTextField(text: $store.text) { config in
                                        config.autocapitalization = style.autocapitalization
                                        config.autocorrection = style.autocorrectionDisabled ? .no : .yes
                                        config.isFirstResponder = !store.collapsed
                                        config.onCommit = { store.send(.delegate(.fieldCommitted)) }
                                        config.placeholder = placeholder
                                        config.preferredLanguage = store.language.bcp47
                                        config.onLanguageUnavailable = {
                                            print("Could not resolve language with identifier: \($0)")
                                        }
                                    }
                                case .editor:
                                    ConfigurableTextView(text: $store.text) { config in
                                        config.autocapitalization = style.autocapitalization
                                        config.autocorrection = style.autocorrectionDisabled ? .no : .yes
                                        config.isFirstResponder = !store.collapsed
                                        config.onCommit = { store.send(.delegate(.fieldCommitted)) }
                                        config.preferredLanguage = store.language.bcp47
                                        config.onLanguageUnavailable = {
                                            print("Could not resolve language with identifier: \($0)")
                                        }
                                    }
                                    .multilineTextAlignment(.leading)
                                }
                            }
                        case .swiftUI:
                            Group {
                                switch style.entryStyle {
                                case .field:
                                    TextField(placeholder, text: $store.text)
                                case .editor:
                                    TextEditor(text: $store.text)
                                }
                            }
                            .onSubmit {
                                store.send(.delegate(.fieldCommitted))
                            }
                            .autocapitalization(style.autocapitalization)
                            .autocorrectionDisabled(style.autocorrectionDisabled)
                        }
                    }
                    .id(store.language.id)
                    .font(style.font)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .padding(.leading)
                    .frame(maxWidth: store.collapsed ? 0 : .infinity, maxHeight: .infinity)
                    /* 
                     Note: You can't use a conditional for the ConfigurableTextField, because
                     the delays associated with installing and uninstalling the UIView make the
                     interface while simultaneously dismissing and pushing egregious. Thus
                     we are using the frame to make it collapse (and the 0 spacing on the HStack)
                     */
                    
                    AddOrClearButton(rotated: !store.collapsed)  {
                        store.send(.rotatingButtonTapped)
                    }
                    
                    if !store.collapsed {
                        SaveEntryButton {
                            store.send(.delegate(.saveEntryButtonTapped))
                        }
                    }
                    
                }
                .padding()
            }
            .frame(width: store.collapsed ? proxy.size.height : proxy.size.width)
        }
        .animation(.default, value: store.collapsed)
        .compositingGroup()
        .shadow(radius: 2, x: 1, y: 2)
        .frame(height: style.customHeight ?? 70)
    }
}

extension View {
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { _, new in second.wrappedValue = new }
            .onChange(of: second.wrappedValue) { _, new in first.wrappedValue = new }
    }
}


struct SaveEntryButton: View {

    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "checkmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .contentShape(Circle())
            .onTapGesture(perform: onTap)
            .padding(.leading, 4)
            .transition(.scale)
    }
}



extension EnvironmentValues {
    var floatingTextField: FloatingTextFieldView.Style {
        get { self[FloatingTextFieldView.Style.self] }
        set { self[FloatingTextFieldView.Style.self] = newValue}
    }
}

//#Preview { Preview }
//private var Preview: some View {
//    FloatingTextFieldView(
//        store: .init(initialState: .init(trackedLanguages: Shared([Language.ID]())), reducer: { FloatingTextField() })
//    )
//}
