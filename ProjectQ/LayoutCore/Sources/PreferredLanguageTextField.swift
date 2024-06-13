
import SwiftUI

#if os(iOS)
/**
 Note: The primary motivation for using this wrapper around a UITextField is that SwiftUI does not currently
 offer a way to specify the preferredLanguage setting on the TextField that will automatically switch the
 keyboard language, like we can with a UITextField.
 
 Note 2: The warning:
 -[RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:]  perform input operation requires a valid sessionID. inputModality = Keyboard, inputOperation = dismissAutoFillPanel, customInfoType = UIUserInteractionRemoteInputOperations
  does not seem to affect functionality, and doesn't seem to have a cause I could find, so we will be ignoring it for now.
 */
public struct PreferredLanguageTextField {
    
    public init(
        placeholder: String? = nil,
        text: Binding<String>,
        isFocused: Binding<Bool>,
        preferredLanguage: String? = nil,
        autocapitalization: Autocapitalization,
        autocorrection: Autocorrection,
        adjustsFontSizeToFitWidth: Bool,
        onLanguageUnavailable: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self._text = text
        self._isFocused = isFocused
        self.preferredLanguage = preferredLanguage
        self.autocapitalization = autocapitalization
        self.autocorrection = autocorrection
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.onLanguageUnavailable = onLanguageUnavailable
        self.onSubmit = onSubmit
    }
    
    var placeholder: String?
    @Binding var text: String
    @Binding var isFocused: Bool
    var preferredLanguage: String?
    var autocapitalization: Autocapitalization = .none
    var autocorrection: Autocorrection = .default
    var adjustsFontSizeToFitWidth: Bool = false
    var onLanguageUnavailable: (String) -> Void = { _ in }
    var onSubmit: () -> Void = { }

}

public enum Autocapitalization {
    case allCharacters
    case words
    case sentences
    case none
}

public enum Autocorrection {
    case `default`
    case no
    case yes
}

extension Autocapitalization {
    var uiTextAutocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .allCharacters: .allCharacters
        case .none: .none
        case .words: .words
        case .sentences: .sentences
        }
    }
}

extension Autocorrection {
    var uiTextAutocorrectionType: UITextAutocorrectionType {
        switch self {
        case .default: return .default
        case .no: return .no
        case .yes: return .yes
        }
    }
}

extension PreferredLanguageTextField: UIViewRepresentable {
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PreferredLanguageTextField
        
        public init(parent: PreferredLanguageTextField) {
            self.parent = parent
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            Task { @MainActor in
                self.parent.isFocused = true
            }
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField) {
            Task { @MainActor in
                self.parent.isFocused = false
            }
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            Task { @MainActor in
                self.parent.onSubmit()
            }
            return true
        }
        
        // This updates the text binding's wrappedValue so that it reflects the underlying UITextField's `text` property
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            guard textField.markedTextRange == nil, parent.text != textField.text else {
                return
            }
            
            parent.text = textField.text ?? ""
        }

    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public func makeUIView(context: Context) -> PreferredLanguageUITextField {
        let textField = PreferredLanguageUITextField()
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.preferredLanguage = preferredLanguage ?? context.environment.locale.identifier
        textField.onLanguageUnavailable = onLanguageUnavailable
        return textField
    }
    
    public func updateUIView(_ textField: PreferredLanguageUITextField, context: Context) {
        
        textField.text = text
        
        // focus
        if isFocused {
            if !textField.isFirstResponder {
                Task { @MainActor in
                    textField.becomeFirstResponder()
                }
            }
        } else {
            if textField.isFirstResponder {
                Task { @MainActor in
                    textField.resignFirstResponder()
                }
            }
        }
        
        // autocorrect and capitalization
        textField.autocapitalizationType = autocapitalization.uiTextAutocapitalizationType
        textField.autocorrectionType = autocorrection.uiTextAutocorrectionType
        textField.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth

        // attributed placeholder
        if let placeholder {
            let style = NSMutableParagraphStyle()
            switch context.environment.multilineTextAlignment {
            case .center:
                style.alignment = .center
            case .leading:
                style.alignment = .left
            case .trailing:
                style.alignment = .right
            }
            
            var attributes = [NSAttributedString.Key: Any]()
            if let font = context.environment.font?.toUIFont() {
                attributes[.font] = font
            }
            attributes[.paragraphStyle] = style
            textField.attributedPlaceholder = NSAttributedString(
                string: "\(placeholder)",
                attributes: attributes
            )
            
        } else {
            textField.attributedPlaceholder = nil
            textField.placeholder = nil
        }

        // Environment injection
        textField.isUserInteractionEnabled = context.environment.isEnabled
        textField.font = context.environment.font?.toUIFont()
        switch context.environment.multilineTextAlignment {
        case .center:
            textField.textAlignment = .center
        case .leading:
            textField.textAlignment = .left
        case .trailing:
            textField.textAlignment = .right
        }
        
    }
}

private extension Font {
    func toUIFont() -> UIFont? {
        switch self {
        case .largeTitle:
            .preferredFont(forTextStyle: .largeTitle)
        case .title:
            .preferredFont(forTextStyle: .title1)
        case .title2:
            .preferredFont(forTextStyle: .title2)
        case .title3:
            .preferredFont(forTextStyle: .title3)
        case .headline:
            .preferredFont(forTextStyle: .headline)
        case .subheadline:
            .preferredFont(forTextStyle: .subheadline)
        case .body:
            .preferredFont(forTextStyle: .body)
        case .callout:
            .preferredFont(forTextStyle: .callout)
        case .footnote:
            .preferredFont(forTextStyle: .footnote)
        case .caption:
            .preferredFont(forTextStyle: .caption1)
        case .caption2:
            .preferredFont(forTextStyle: .caption2)
        default:
            nil
        }
    }
}

public class PreferredLanguageUITextField: UITextField {
    var preferredLanguage: String?
    var onLanguageUnavailable: ((String) -> Void)?

    public override var textInputMode: UITextInputMode? {
        guard let preferredLanguage = preferredLanguage else {
            return super.textInputMode
        }
        guard let matchingInputMode = UITextInputMode.activeInputModes.filter({$0.primaryLanguage == preferredLanguage}).first else {
            onLanguageUnavailable?(preferredLanguage)
            return super.textInputMode
        }
        return matchingInputMode
    }
    
}


#endif
