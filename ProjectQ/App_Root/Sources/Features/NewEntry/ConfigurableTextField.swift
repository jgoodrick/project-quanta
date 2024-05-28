
import SwiftUI

/*
 Note: The primary motivation for using this wrapper around a UITextField is that SwiftUI does not currently
 offer a way to specify the preferredLanguage setting on the TextField that will automatically switch the
 keyboard language, like we can with a UITextField. Otherwise, the goal of this type is to allow us to keep the same
 modifiers we would use with a regular SwiftUI TextField at the call site, so that if they eventually add
 that functionality to TextField, or if the requirements change so that we don't need the keyboard switching behavior,
 then the TextField becomes a drop-in replacement.
 */

struct ConfigurableTextField: UIViewRepresentable {
    
    init(text: Binding<String>, configurationModifications: (inout Configuration) -> Void) {
        var config = Configuration()
        configurationModifications(&config)
        self.configuration = config
        self.text = text
    }
        
    init(text: Binding<String>, configuration: Configuration) {
        self.configuration = configuration
        self.text = text
    }
        
    var text: Binding<String>
    var configuration: Configuration
    
    typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)
    
    struct CharactersChange {
        let range: NSRange
        let replacement: String
    }
    
    struct Configuration {
        var preferredLanguage: String?
        
        var onEditingChanged: (Bool) -> Void = { _ in }
        var isEditing: Binding<Bool>? = .none
        var onCommit: () -> Void = { }
        var onDeleteBackward: () -> Void = { }
        var onCharactersChange: (CharactersChange) -> Bool = { _ in true }
        var onLanguageUnavailable: (String) -> Void = { _ in }
        
        var textRect: Rect?
        var editingRect: Rect?
        var clearButtonRect: Rect?
        
        var isInitialFirstResponder: Bool?
        var isFirstResponder: Bool?
        var becomeFirstResponderDelayNanoseconds: Double = 0
        
        var autocapitalization: UITextAutocapitalizationType?
        var borderStyle: UITextField.BorderStyle = .none
        var uiFont: UIFont?
        var keyboardType: UIKeyboardType = .default
        var placeholder: String?
        var returnKeyType: UIReturnKeyType?
        var textColor: UIColor?
        var textContentType: UITextContentType?
        var secureTextEntry: Bool?
        var clearButtonMode: UITextField.ViewMode?
        var enablesReturnKeyAutomatically: Bool? = true
        var returnKeyEnabled: Bool? = true // only works with enablesReturnKeyAutomatically set to true
        var adjustsFontSizeToFitWidth: Bool?
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var configuration: Configuration
        
        init(text: Binding<String>, configuration: Configuration) {
            self.text = text
            self.configuration = configuration
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            configuration.isEditing?.wrappedValue = true
            configuration.onEditingChanged(true)
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            guard textField.markedTextRange == nil, text.wrappedValue != textField.text else {
                return
            }
            
            text.wrappedValue = textField.text ?? ""
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            configuration.isEditing?.wrappedValue = false
            configuration.onEditingChanged(false)
        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            configuration.onCharactersChange(.init(range: range, replacement: string))
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            var nextField: UIView?
            
            if textField.tag != 0 {
                let nextTag = textField.tag + 1
                var parentView = textField.superview
                
                while nextField == nil && parentView != nil {
                    nextField = parentView?.viewWithTag(nextTag)
                    parentView = parentView?.superview
                }
            }
            
            if let nextField = nextField {
                nextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            configuration.onCommit()
            return true
        }
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView = UITextFieldSubclass()
                
        uiView.preferredLanguage = configuration.preferredLanguage ?? context.environment.locale.identifier
        
        uiView.onLanguageUnavailable = configuration.onLanguageUnavailable
        uiView.hasTextOverride = configuration.returnKeyEnabled
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        uiView.delegate = context.coordinator
        
        if let isInitialFirstResponder = configuration.isInitialFirstResponder, isInitialFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.becomeFirstResponderDelayNanoseconds) {
                uiView.becomeFirstResponder()
            }
        }
        
        return uiView
    }
    
    func updateUIView(_ uiView: UITextFieldSubclass, context: Context) {
        context.coordinator.text = text
        context.coordinator.configuration = configuration
        
        uiView.preferredLanguage = configuration.preferredLanguage ?? context.environment.locale.identifier

        uiView.onDeleteBackward = configuration.onDeleteBackward
        
        uiView.textRect = configuration.textRect
        uiView.editingRect = configuration.editingRect
        uiView.clearButtonRect = configuration.clearButtonRect
        
        if let autocapitalization = configuration.autocapitalization {
            uiView.autocapitalizationType = autocapitalization
        } else {
            uiView.autocapitalizationType = .sentences
        }
        
        uiView.borderStyle = configuration.borderStyle
        
        if let disableAutocorrection = context.environment.disableAutocorrection {
            uiView.autocorrectionType = disableAutocorrection ? .no : .yes
        } else {
            uiView.autocorrectionType = .default
        }
        
        uiView.font = configuration.uiFont ?? context.environment.font?.toUIFont()
        
        uiView.isUserInteractionEnabled = context.environment.isEnabled
        
        uiView.keyboardType = configuration.keyboardType
        
        if let placeholder = configuration.placeholder {
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
            if let font = configuration.uiFont ?? context.environment.font?.toUIFont() {
                attributes[.font] = font
            }
            attributes[.paragraphStyle] = style
            uiView.attributedPlaceholder = NSAttributedString(
                string: "\(placeholder)",
                attributes: attributes
            )
            
        } else {
            uiView.attributedPlaceholder = nil
            uiView.placeholder = nil
        }
        
        if let returnKeyType = configuration.returnKeyType {
            uiView.returnKeyType = returnKeyType
        } else {
            uiView.returnKeyType = .default
        }
        
        if let textColor = configuration.textColor {
            uiView.textColor = textColor
        }
        
        if let textContentType = configuration.textContentType {
            uiView.textContentType = textContentType
        } else {
            uiView.textContentType = nil
        }
        
        if let secureTextEntry = configuration.secureTextEntry {
            uiView.isSecureTextEntry = secureTextEntry
        } else {
            uiView.isSecureTextEntry = false
        }
        
        if let clearButtonMode = configuration.clearButtonMode {
            uiView.clearButtonMode = clearButtonMode
        } else {
            uiView.clearButtonMode = .never
        }
        
        if let enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically {
            uiView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        } else {
            uiView.enablesReturnKeyAutomatically = false
        }
        
        if let returnKeyEnabled = configuration.returnKeyEnabled {
            uiView.hasTextOverride = returnKeyEnabled
        } else {
            uiView.hasTextOverride = nil
        }
        
        if let adjustsFontSizeToFitWidth = configuration.adjustsFontSizeToFitWidth {
            uiView.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        } else {
            uiView.adjustsFontSizeToFitWidth = false
        }
        
        uiView.text = text.wrappedValue
        switch context.environment.multilineTextAlignment {
        case .center:
            uiView.textAlignment = .center
        case .leading:
            uiView.textAlignment = .left
        case .trailing:
            uiView.textAlignment = .right
        }
        
        
        DispatchQueue.main.async {
            if let isFirstResponder = configuration.isFirstResponder, uiView.window != nil {
                if isFirstResponder && !uiView.isFirstResponder, context.environment.isEnabled {
                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.becomeFirstResponderDelayNanoseconds) {
                        uiView.becomeFirstResponder()
                    }
                } else if !isFirstResponder && uiView.isFirstResponder {
                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.becomeFirstResponderDelayNanoseconds) {
                        uiView.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(text: text, configuration: configuration)
    }
}

final class UITextFieldSubclass: UITextField {
    var preferredLanguage: String?
    var onLanguageUnavailable: ((String) -> Void)?
    var onDeleteBackward: (() -> Void)?
    var hasTextOverride: Bool?
    
    var textRect: ConfigurableTextField.Rect?
    var editingRect: ConfigurableTextField.Rect?
    var clearButtonRect: ConfigurableTextField.Rect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward?()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.textRect(forBounds: bounds)
        
        return textRect?(bounds, original) ?? original
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.editingRect(forBounds: bounds)
        
        return editingRect?(bounds, original) ?? original
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.clearButtonRect(forBounds: bounds)
        
        return clearButtonRect?(bounds, original) ?? original
    }
    
    override var textInputMode: UITextInputMode? {
        guard let preferredLanguage = preferredLanguage else {
            return super.textInputMode
        }
        guard let matchingInputMode = UITextInputMode.activeInputModes.filter({$0.primaryLanguage == preferredLanguage}).first else {
            onLanguageUnavailable?(preferredLanguage)
            return super.textInputMode
        }
        return matchingInputMode
    }
    
    override var hasText: Bool {
        guard let hasTextOverride else { return super.hasText }
        return hasTextOverride
    }
}

private extension Font.TextStyle {
    func toUIFontTextStyle() -> UIFont.TextStyle? {
        switch self {
        #if !os(tvOS)
        case .largeTitle:
            return .largeTitle
        #endif
        case .title:
            return .title1
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        default:
            do {
                switch self {
                case .title2:
                    return .title2
                case .title3:
                    return .title3
                case .caption2:
                    return .caption2
                default:
                    do {
                        assertionFailure()
                        return .body
                    }
                }
            }
        }
    }
}

private extension Font {
    func getTextStyle() -> TextStyle? {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        default:
            return nil
        }
    }
    
    func toUIFont() -> UIFont? {
        guard let textStyle = getTextStyle()?.toUIFontTextStyle() else {
            return nil
        }
        
        return .preferredFont(forTextStyle: textStyle)
    }
}
