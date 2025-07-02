//
//  Locale+LocalizedNameOf.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import Foundation

extension Locale {
    func languageName(of identifier: String, native: Bool, capitalized: Bool) -> String? {
        if native {
            let nativeLocale = Locale(identifier: identifier)
            let name = nativeLocale.localizedString(forIdentifier: identifier)
            if capitalized {
                return name?.capitalized(with: nativeLocale)
            } else {
                return name
            }
        } else {
            let name = localizedString(forIdentifier: identifier)
            if capitalized {
                return name?.capitalized(with: self)
            } else {
                return name
            }
        }
    }
}
