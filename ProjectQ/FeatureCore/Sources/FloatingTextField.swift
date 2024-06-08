
import ComposableArchitecture
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct FloatingTextField {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        public init(
            matching: TranslatableEntity? = nil,
            languageOverride: Language.ID? = nil,
            text: String = "",
            collapsed: Bool = true
        ) {
            self.matching = matching
            self.languageOverride = languageOverride
            self.text = text
            self.collapsed = collapsed
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        public var matching: TranslatableEntity?
        public var languageOverride: Language.ID?
        public var text: String = ""
        public var collapsed: Bool = true
        
        var overriddenLanguage: Language.ID? {
            @Dependency(\.systemLanguages) var systemLanguages
            return languageOverride ?? matching.flatMap({
                db.keyboardLanguageID(for: $0) ?? systemLanguages.current().id
            })
        }
        public var language: Language {
            overriddenLanguage.flatMap({ db[language: $0] }) ?? settings.focusedLanguage
        }
        
        public mutating func reset() {
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
    
    public init(store: StoreOf<FloatingTextField>, placeholder: String) {
        self.store = store
        self.placeholder = placeholder
    }
    
    @SwiftUI.Bindable var store: StoreOf<FloatingTextField>
    let placeholder: String

    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
        public var customHeight: Double? = .none
        public var font: Font = .title2
        public var background: Color = .gray
        public var autocapitalization: UITextAutocapitalizationType = .none
        public var autocorrectionDisabled: Bool = true
        public var implementation: Implementation = .uiKit
        public enum Implementation {
            case uiKit
            case swiftUI
        }
        public var entryStyle: EntryStyle = .field
        public enum EntryStyle {
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
    public var floatingTextField: FloatingTextFieldView.Style {
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
