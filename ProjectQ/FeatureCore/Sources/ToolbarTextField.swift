
import ComposableArchitecture
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct ToolbarTextField {
    
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
        public var focused: Bool {
            get { !collapsed }
            set { collapsed = !newValue }
        }
        
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
        case tappedViewBehindActiveToolbarTextField
        case couldNotResolveLanguageIdentifier(preferredLanguage: String)
        
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
                
            case .couldNotResolveLanguageIdentifier(let identifier):
                
                // TODO: show alert to user directing them to Settings
                
                print("Could not resolve preferred language with identifier: \(identifier). Store language was currently set to: \(state.language)")

                return .none
                
            case .rotatingButtonTapped, .tappedViewBehindActiveToolbarTextField:
                
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

#if os(iOS)

public struct ToolbarTextFieldView: View {
    
    public init(store: StoreOf<ToolbarTextField>, placeholder: String) {
        self.store = store
        self.placeholder = placeholder
    }
    
    @Bindable var store: StoreOf<ToolbarTextField>
    let placeholder: String

    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
        public var customHeight: Double? = .none
        public var font: Font = .title2
        public var background: Color = .gray
        public var autocapitalization: Autocapitalization = .none
        public var autocorrection: Autocorrection = .default
    }
    
    @Environment(\.toolbarTextField) var style
    @FocusState private var focused: Bool

    var languageIdentifier: String { store.language.bcp47.rawValue }

    public var body: some View {
        HStack(spacing: 0) {
            PreferredLanguageTextField.init(
                placeholder: placeholder,
                text: $store.text,
                isFocused: $store.focused,
                preferredLanguage: languageIdentifier,
                autocapitalization: style.autocapitalization,
                autocorrection: style.autocorrection,
                adjustsFontSizeToFitWidth: true,
                onLanguageUnavailable: {
                    store.send(.couldNotResolveLanguageIdentifier(preferredLanguage: $0))
                },
                onSubmit: { store.send(.delegate(.fieldCommitted)) }
            )
            .id(store.language.id)
            .font(style.font)
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
            
            SaveEntryButton {
                store.send(.delegate(.saveEntryButtonTapped))
            }
            .opacity(store.collapsed ? 0 : 1.0)
            .frame(width: store.collapsed ? 0 : .none)
            .geometryGroup() // allows the geometry of this view's animations to be resolved at each step of the parent's frame changes

        }
        .padding()
        .background {
            Capsule()
                .fill(.background)
        }
        .animation(.default, value: store.collapsed)
        .compositingGroup()
        .shadow(radius: 2, x: 1, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: style.customHeight ?? 70)
        .synchronize($store.focused, $focused)
    }
}

struct SaveEntryButton: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "checkmark.circle")
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(minWidth: 1) // this line prevents a bug where the image disappears immediately instead of animating away
            .padding(.leading, 4)
            .contentShape(Circle())
            .onTapGesture(perform: onTap)
    }
}

public struct ToolbarTextFieldInstaller: ViewModifier {
    
    public init(
        store: StoreOf<ToolbarTextField>,
        placeholder: String,
        autocapitalization: Autocapitalization = .none
    ) {
        self.store = store
        self.placeholder = placeholder
        self.autocapitalization = autocapitalization
    }
    
    let store: StoreOf<ToolbarTextField>
    let placeholder: String
    var autocapitalization: Autocapitalization = .none

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
//                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    if !store.collapsed {
                        Rectangle().fill(.background).opacity(0.4).onTapGesture {
                            store.send(.tappedViewBehindActiveToolbarTextField)
                        }
                        ToolbarTextFieldView(
                            store: store,
                            placeholder: placeholder
                        )
                        .padding()
                        .transformEnvironment(\.toolbarTextField) {
                            $0.autocapitalization = autocapitalization
                        }
                    }
//                }
        }
    }
}

extension EnvironmentValues {
    public var toolbarTextField: ToolbarTextFieldView.Style {
        get { self[ToolbarTextFieldView.Style.self] }
        set { self[ToolbarTextFieldView.Style.self] = newValue}
    }
}

#Preview { Preview }
private var Preview: some View {
    ToolbarTextFieldView(
        store: .init(initialState: .init(), reducer: { ToolbarTextField() }),
        placeholder: "placeholder text"
    )
}

#endif

