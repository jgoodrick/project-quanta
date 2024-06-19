
#if os(iOS)

import StructuralModel // Language
import SwiftUI

struct ToolbarTextFieldView: View {
        
    let placeholder: String
    let language: Language
    @Binding var text: String
    @Binding var focused: Bool
    let onLanguageUnavailable: (String) -> Void
    let onSaveButtonTapped: () -> Void
    let onSubmit: () -> Void
    
    func reset() {
        text = ""
        focused = false
    }
    
    struct Style: EnvironmentKey {
        static var defaultValue: Self = .init()
        var customHeight: Double? = .none
        var font: Font = .title2
        var background: Color = .gray
        var autocapitalization: Autocapitalization = .none
        var autocorrection: Autocorrection = .default
    }
    
    @Environment(\.toolbarTextField) var style
    @FocusState private var focusState: Bool

    var languageIdentifier: String { language.bcp47.rawValue }

    var body: some View {
        HStack(spacing: 0) {
            PreferredLanguageTextField.init(
                placeholder: placeholder,
                text: $text,
                isFocused: $focused,
                preferredLanguage: languageIdentifier,
                autocapitalization: style.autocapitalization,
                autocorrection: style.autocorrection,
                adjustsFontSizeToFitWidth: true,
                onLanguageUnavailable: onLanguageUnavailable,
                onSubmit: onSubmit
            )
            .id(language.id)
            .font(style.font)
            .padding(.leading)
            .frame(maxWidth: !focused ? 0 : .infinity, maxHeight: .infinity)
            /*
             Note: You can't use a conditional for the ConfigurableTextField, because
             the delays associated with installing and uninstalling the UIView make the
             interface while simultaneously dismissing and pushing egregious. Thus
             we are using the frame to make it collapse (and the 0 spacing on the HStack)
             */
            
            AddOrClearButton(rotated: focused, onTap: {
                if focused {
                    reset()
                } else {
                    focused = true
                }
            })
            
            SaveButton(onTap: {
                onSaveButtonTapped()
                reset()
            })
            .opacity(!focused ? 0 : 1.0)
            .frame(width: !focused ? 0 : .none)
            .geometryGroup() // allows the geometry of this view's animations to be resolved at each step of the parent's frame changes

        }
        .padding()
        .background {
            Capsule()
                .fill(.background)
        }
        .animation(.default, value: !focused)
        .compositingGroup()
        .shadow(radius: 2, x: 1, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: style.customHeight ?? 70)
        .synchronize($focused, $focusState)
    }
    
    struct SaveButton: View {
        
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
}


public struct ToolbarTextFieldInstaller: ViewModifier {
    
    public init(
        placeholder: String,
        language: Language,
        text: Binding<String>,
        focused: Binding<Bool>,
        installed: Bool,
        onLanguageUnavailable: @escaping (String) -> Void,
        onSaveButtonTapped: @escaping () -> Void,
        onSubmit: @escaping () -> Void,
        tappedViewBehindActiveToolbarTextField: @escaping () -> Void,
        autocapitalization: Autocapitalization = .none
    ) {
        self.placeholder = placeholder
        self.language = language
        self._text = text
        self._focused = focused
        self.installed = installed
        self.onLanguageUnavailable = onLanguageUnavailable
        self.onSaveButtonTapped = onSaveButtonTapped
        self.onSubmit = onSubmit
        self.tappedViewBehindActiveToolbarTextField = tappedViewBehindActiveToolbarTextField
        self.autocapitalization = autocapitalization
    }
    
    let placeholder: String
    let language: Language
    @Binding var text: String
    @Binding var focused: Bool
    let installed: Bool
    let onLanguageUnavailable: (String) -> Void
    let onSaveButtonTapped: () -> Void
    let onSubmit: () -> Void
    let tappedViewBehindActiveToolbarTextField: () -> Void
    let autocapitalization: Autocapitalization

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            
            content
            
            if installed {
                
                if focused {
                    Rectangle()
                        .fill(.background)
                        .opacity(0.4)
                        .onTapGesture {
                            tappedViewBehindActiveToolbarTextField()
                            text = ""
                            focused = false
                        }
                }
                
                ToolbarTextFieldView(
                    placeholder: placeholder,
                    language: language,
                    text: $text,
                    focused: $focused,
                    onLanguageUnavailable: onLanguageUnavailable,
                    onSaveButtonTapped: onSaveButtonTapped,
                    onSubmit: onSubmit
                )
                .padding()
                .transformEnvironment(\.toolbarTextField) {
                    $0.autocapitalization = autocapitalization
                }
            }
        }
    }
}

extension EnvironmentValues {
    var toolbarTextField: ToolbarTextFieldView.Style {
        get { self[ToolbarTextFieldView.Style.self] }
        set { self[ToolbarTextFieldView.Style.self] = newValue}
    }
}

#Preview { Host() }
private struct Host: View {
    @State private var text: String = ""
    @State private var focused: Bool = false
    var body: some View {
        List(0..<100) { i in
            Text("\(i)")
        }
        .modifier(
            ToolbarTextFieldInstaller(
                placeholder: "placeholder text",
                language: .ukrainian,
                text: $text,
                focused: $focused,
                installed: true,
                onLanguageUnavailable: { print("\($0) is unavailable")},
                onSaveButtonTapped: { print("tapped save button: \(text)") },
                onSubmit: { print("submitted the text field: \(text)") },
                tappedViewBehindActiveToolbarTextField: { print("tapped background") }
            )
        )
    }
}

#endif
