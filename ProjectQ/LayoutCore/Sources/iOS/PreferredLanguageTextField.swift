
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
    public var isDisabled: Bool {
        switch self {
        case .no: return true
        default: return false
        }
    }
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
    
    public typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PreferredLanguageTextField
        var textRect: Rect?
        var editingRect: Rect?

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

        textField.textRect = context.coordinator.textRect
        textField.editingRect = context.coordinator.editingRect

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

    var textRect: PreferredLanguageTextField.Rect?
    var editingRect: PreferredLanguageTextField.Rect?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.textRect(forBounds: bounds)
        
        return textRect?(bounds, original) ?? original
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.editingRect(forBounds: bounds)
        
        return editingRect?(bounds, original) ?? original
    }

}


public struct ConfigurableTextField {
    
    public init(text: Binding<String>, configurationModifications: (inout Configuration) -> Void) {
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
    
}

extension ConfigurableTextField {
    
    public typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)
    
    public struct CharactersChange {
        public let range: NSRange
        public let replacement: String
    }
    
    public struct Configuration {
        public var preferredLanguage: String?
        
        public var onEditingChanged: (Bool) -> Void = { _ in }
        public var isEditing: Binding<Bool>? = .none
        public var onCommit: () -> Void = { }
        public var onDeleteBackward: () -> Void = { }
        public var onCharactersChange: (CharactersChange) -> Bool = { _ in true }
        public var onLanguageUnavailable: (String) -> Void = { _ in }
        
        public var textRect: Rect?
        public var editingRect: Rect?
        public var clearButtonRect: Rect?
        
        public var isInitialFirstResponder: Bool?
        public var isFirstResponder: Bool?
        public var becomeFirstResponderDelayNanoseconds: Double = 0
        
        public var placeholder: String?
        public var secureTextEntry: Bool?
        public var enablesReturnKeyAutomatically: Bool? = true
        public var returnKeyEnabled: Bool? = true // only works with enablesReturnKeyAutomatically set to true
        public var adjustsFontSizeToFitWidth: Bool?
        public var autocapitalization: Autocapitalization = .none
        public var autocorrectionDisabled: Bool = false

        public var borderStyle: UITextField.BorderStyle = .none
        public var uiFont: UIFont?
        public var keyboardType: UIKeyboardType = .default
        public var returnKeyType: UIReturnKeyType?
        public var textColor: UIColor?
        public var textContentType: UITextContentType?
        public var clearButtonMode: UITextField.ViewMode?
    }
    
}

extension ConfigurableTextField: UIViewRepresentable {
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var configuration: Configuration
        
        init(text: Binding<String>, configuration: Configuration) {
            self.text = text
            self.configuration = configuration
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            configuration.isEditing?.wrappedValue = true
            configuration.onEditingChanged(true)
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            guard textField.markedTextRange == nil, text.wrappedValue != textField.text else {
                return
            }
            
            text.wrappedValue = textField.text ?? ""
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            configuration.isEditing?.wrappedValue = false
            configuration.onEditingChanged(false)
        }
        
        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            configuration.onCharactersChange(.init(range: range, replacement: string))
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    public func makeUIView(context: Context) -> UIViewType {
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
    
    public func updateUIView(_ uiView: UITextFieldSubclass, context: Context) {
        context.coordinator.text = text
        context.coordinator.configuration = configuration
        
        uiView.preferredLanguage = configuration.preferredLanguage ?? context.environment.locale.identifier

        uiView.onDeleteBackward = configuration.onDeleteBackward
        
        uiView.textRect = configuration.textRect
        uiView.editingRect = configuration.editingRect
        uiView.clearButtonRect = configuration.clearButtonRect
        
        switch configuration.autocapitalization {
        case .allCharacters: uiView.autocapitalizationType = .allCharacters
        case .none: uiView.autocapitalizationType = .none
        case .words: uiView.autocapitalizationType = .words
        case .sentences: uiView.autocapitalizationType = .sentences
        }
        
        uiView.autocorrectionType = configuration.autocorrectionDisabled ? .no : .default
        
        uiView.borderStyle = configuration.borderStyle
                
        uiView.font = configuration.uiFont ?? context.environment.font?.toConfigurableUIFont()
        
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
            if let font = configuration.uiFont ?? context.environment.font?.toConfigurableUIFont() {
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
    
    public func makeCoordinator() -> Coordinator {
        .init(text: text, configuration: configuration)
    }
}

public final class UITextFieldSubclass: UITextField {
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
    
    public override func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward?()
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.textRect(forBounds: bounds)
        
        return textRect?(bounds, original) ?? original
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.editingRect(forBounds: bounds)
        
        return editingRect?(bounds, original) ?? original
    }
    
    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.clearButtonRect(forBounds: bounds)
        
        return clearButtonRect?(bounds, original) ?? original
    }
    
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
    
    public override var hasText: Bool {
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
    
    func toConfigurableUIFont() -> UIFont? {
        guard let textStyle = getTextStyle()?.toUIFontTextStyle() else {
            return nil
        }
        
        return .preferredFont(forTextStyle: textStyle)
    }
}


#endif
