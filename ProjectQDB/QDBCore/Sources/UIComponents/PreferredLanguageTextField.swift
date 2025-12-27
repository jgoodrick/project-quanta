//
//  PreferredLanguageTextField.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

#if os(iOS)
import SwiftUI

/**
 Note: The primary motivation for using this wrapper around a UITextField is that SwiftUI does not currently
 offer a way to specify the preferredLanguage setting on the TextField that will automatically switch the
 keyboard language, like we can with a UITextField.

 Note 2: The warning:
 -[RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:]  perform input operation requires a valid sessionID. inputModality = Keyboard, inputOperation = dismissAutoFillPanel, customInfoType = UIUserInteractionRemoteInputOperations
 does not seem to affect functionality, and doesn't seem to have a cause I could find, so we will be ignoring it for now.
 */
public struct PreferredLanguageTextField: View {
    public init(
        placeholder: String? = nil,
        style: Style = .defaultValue,
        text: Binding<String>,
        isFocused: Binding<Bool>,
        preferredLanguage: String? = nil,
        onLanguageAvailability: @escaping (String, Bool) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.style = style
        self._text = text
        self._isFocused = isFocused
        self.preferredLanguage = preferredLanguage
        self.onLanguageAvailability = onLanguageAvailability
        self.onSubmit = onSubmit
    }

    var placeholder: String?
    var style: Style = .defaultValue
    @Binding var text: String
    @Binding var isFocused: Bool
    var preferredLanguage: String?
    var onLanguageAvailability: (String, Bool) -> Void
    var onSubmit: () -> Void = { }

    public struct Style: Sendable {
        public static let defaultValue: Self = .init()
        public var font: Font = .title2
        public var autocapitalization: Autocapitalization = .none
        public var autocorrection: Autocorrection = .default
        public var adjustsFontSizeToFitWidth: Bool = false
    }

    public var body: some View {
        Representable(
            placeholder: placeholder,
            text: $text,
            isFocused: $isFocused,
            preferredLanguage: preferredLanguage,
            autocapitalization: style.autocapitalization,
            autocorrection: style.autocorrection,
            adjustsFontSizeToFitWidth: style.adjustsFontSizeToFitWidth,
            onLanguageAvailability: onLanguageAvailability,
            onSubmit: onSubmit
        )
        .id(preferredLanguage)
        .font(style.font)
    }
}

public extension PreferredLanguageTextField {
    struct Representable {
        public init(
            placeholder: String? = nil,
            text: Binding<String>,
            isFocused: Binding<Bool>,
            preferredLanguage: String? = nil,
            autocapitalization: Autocapitalization,
            autocorrection: Autocorrection,
            adjustsFontSizeToFitWidth: Bool,
            onLanguageAvailability: @escaping (String, Bool) -> Void,
            onSubmit: @escaping () -> Void
        ) {
            self.placeholder = placeholder
            self._text = text
            self._isFocused = isFocused
            self.preferredLanguage = preferredLanguage
            self.autocapitalization = autocapitalization
            self.autocorrection = autocorrection
            self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            self.onLanguageAvailability = onLanguageAvailability
            self.onSubmit = onSubmit
        }

        var placeholder: String?
        @Binding var text: String
        @Binding var isFocused: Bool
        var preferredLanguage: String?
        var autocapitalization: Autocapitalization
        var autocorrection: Autocorrection
        var adjustsFontSizeToFitWidth: Bool
        var onLanguageAvailability: (String, Bool) -> Void
        var onSubmit: () -> Void
    }
}

public enum Autocapitalization: Sendable {
    case allCharacters
    case words
    case sentences
    case none
    var uiTextAutocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .allCharacters: .allCharacters
        case .none: .none
        case .words: .words
        case .sentences: .sentences
        }
    }
}

public enum Autocorrection: Sendable {
    case `default`
    case no
    case yes
    public var isDisabled: Bool {
        switch self {
        case .no: return true
        default: return false
        }
    }
    var uiTextAutocorrectionType: UITextAutocorrectionType {
        switch self {
        case .default: return .default
        case .no: return .no
        case .yes: return .yes
        }
    }
}

extension PreferredLanguageTextField.Representable: UIViewRepresentable {

    public typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PreferredLanguageTextField.Representable
        var textRect: Rect?
        var editingRect: Rect?

        public init(parent: PreferredLanguageTextField.Representable) {
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
        textField.onLanguageAvailability = onLanguageAvailability
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
    var onLanguageAvailability: ((String, Bool) -> Void)?

    var textRect: PreferredLanguageTextField.Representable.Rect?
    var editingRect: PreferredLanguageTextField.Representable.Rect?

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
        if let matchingInputMode = UITextInputMode.activeInputModes.filter({$0.primaryLanguage == preferredLanguage}).first {
            onLanguageAvailability?(preferredLanguage, true)
            return matchingInputMode
        } else {
            onLanguageAvailability?(preferredLanguage, false)
            return super.textInputMode
        }
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

#endif
