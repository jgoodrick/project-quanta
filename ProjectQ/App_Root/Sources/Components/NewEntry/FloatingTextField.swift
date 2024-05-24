
import ComposableArchitecture
import SwiftUI

@Reducer
public struct FloatingTextField {
    
    @ObservableState
    public struct State: Equatable {
        public var text: String = ""
        public var collapsed: Bool = true
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
                
                state.collapsed.toggle()
                
                return .none
                
            }
        }
    }
}

public struct FloatingTextFieldView: View {
    
    @Bindable var store: StoreOf<FloatingTextField>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
        var customHeight: Double? = .none
        var background: Color = .gray
        var placeholder: String = "New Entry"
        var textFieldSource: TextFieldSource = .uiKit
        enum TextFieldSource {
            case uiKit
            case swiftUI
        }
    }
    
    @Environment(\.floatingEntryCreator) var style
    @Environment(\.language) var language

    public var body: some View {
        GeometryReader { proxy in
            
            ZStack(alignment: .trailing) {
                
                Capsule()
                    .fill(.background)
                
                HStack(spacing: 0) {
                    Group {
                        switch style.textFieldSource {
                        case .uiKit:
                            ConfigurableTextField(text: $store.text) { config in
                                config.isFirstResponder = !store.collapsed
                                config.onCommit = { store.send(.delegate(.fieldCommitted)) }
                                config.placeholder = style.placeholder
                                config.preferredLanguage = language.bcp47
                                config.onLanguageUnavailable = {
                                    print("Could not resolve language with identifier: \($0)")
                                }
                            }
                            .id(language)
                        case .swiftUI:
                            TextField(style.placeholder, text: $store.text)
                                .onSubmit {
                                    store.send(.delegate(.fieldCommitted))
                                }
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
    var floatingEntryCreator: FloatingTextFieldView.Style {
        get { self[FloatingTextFieldView.Style.self] }
        set { self[FloatingTextFieldView.Style.self] = newValue}
    }
}

#Preview { Preview }
private var Preview: some View {
    VStack {
        FloatingTextFieldView(
            store: .init(initialState: .init(), reducer: { FloatingTextField() })
        )
    }
//    .background(Color.black)
//    .previewLayout(.sizeThatFits)
//    .colorScheme(.dark)
}
