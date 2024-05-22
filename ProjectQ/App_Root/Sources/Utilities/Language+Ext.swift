
import ComposableArchitecture
import SwiftUI

extension Locale {
    
    func displayName(in displayLocale: Locale? = nil, includeSpecifier: Bool = true) -> String {
        
        guard
            let languageCode = language.languageCode?.identifier,
            let displayName = (displayLocale ?? self).localizedString(forLanguageCode: languageCode)
        else {
            return identifier
        }
        
        if includeSpecifier {
            return displayName + " (\(identifier))"
        } else {
            return displayName
        }
    }
    
}

extension Locale: Identifiable {
    public var id: String { identifier } // bcp 47
}
