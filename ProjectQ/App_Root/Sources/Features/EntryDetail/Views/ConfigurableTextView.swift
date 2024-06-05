
import SwiftUI

/*
 See: ConfigurableTextView for more discussion of why this is needed
 */

struct ConfigurableTextView: UIViewRepresentable {
    
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
                
        var isInitialFirstResponder: Bool?
        var isFirstResponder: Bool?
        var becomeFirstResponderDelayNanoseconds: Double = 0
        
        var autocapitalization: UITextAutocapitalizationType = .none
        var borderStyle: UITextView.BorderStyle = .none
        var uiFont: UIFont?
        var keyboardType: UIKeyboardType = .default
        var returnKeyType: UIReturnKeyType?
        var textColor: UIColor?
        var textContentType: UITextContentType?
        var secureTextEntry: Bool?
        var enablesReturnKeyAutomatically: Bool? = true
        var returnKeyEnabled: Bool? = true // only works with enablesReturnKeyAutomatically set to true
        var autocorrection: UITextAutocorrectionType = .default
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var configuration: Configuration
        
        init(text: Binding<String>, configuration: Configuration) {
            self.text = text
            self.configuration = configuration
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            configuration.isEditing?.wrappedValue = true
            configuration.onEditingChanged(true)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard textView.markedTextRange == nil, text.wrappedValue != textView.text else {
                return
            }
            
            text.wrappedValue = textView.text ?? ""
        }
                
        func textView(
            _ textView: UITextView,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            configuration.onCharactersChange(.init(range: range, replacement: string))
        }
        
        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            var nextView: UIView?
            
            if textView.tag != 0 {
                let nextTag = textView.tag + 1
                var parentView = textView.superview
                
                while nextView == nil && parentView != nil {
                    nextView = parentView?.viewWithTag(nextTag)
                    parentView = parentView?.superview
                }
            }
            
            if let nextView = nextView {
                nextView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
            
            configuration.onCommit()
            return true
        }
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView = UITextViewSubclass()
                
        uiView.preferredLanguage = configuration.preferredLanguage ?? context.environment.locale.identifier
        
        uiView.onLanguageUnavailable = configuration.onLanguageUnavailable
        uiView.hasTextOverride = configuration.returnKeyEnabled
                
        uiView.delegate = context.coordinator
        
        if let isInitialFirstResponder = configuration.isInitialFirstResponder, isInitialFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.becomeFirstResponderDelayNanoseconds) {
                uiView.becomeFirstResponder()
            }
        }
        
        return uiView
    }
    
    func updateUIView(_ uiView: UITextViewSubclass, context: Context) {
        context.coordinator.text = text
        context.coordinator.configuration = configuration
        
        uiView.preferredLanguage = configuration.preferredLanguage ?? context.environment.locale.identifier

        uiView.onDeleteBackward = configuration.onDeleteBackward
                
        uiView.autocapitalizationType = configuration.autocapitalization
        
        uiView.autocorrectionType = configuration.autocorrection
        
        uiView.borderStyle = configuration.borderStyle
                
        uiView.font = configuration.uiFont ?? context.environment.font?.toUIFont()
        
        uiView.isUserInteractionEnabled = context.environment.isEnabled
        
        uiView.keyboardType = configuration.keyboardType
                
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

final class UITextViewSubclass: UITextView {
    var preferredLanguage: String?
    var onLanguageUnavailable: ((String) -> Void)?
    var onDeleteBackward: (() -> Void)?
    var hasTextOverride: Bool?
    
    var textRect: ConfigurableTextView.Rect?
    var editingRect: ConfigurableTextView.Rect?
    var clearButtonRect: ConfigurableTextView.Rect?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward?()
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
