//
//  Shared.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import Dependencies
import Foundation
import Sharing

extension SharedKey where Self == AppStorageKey<String>.Default {
    static var languageId: Self {
        @Dependency(\.locale) var locale
        return Self[.appStorage("languageId"), default: locale.language.languageCode?.identifier ?? "en"]
    }
}

extension SharedKey where Self == InMemoryKey<String>.Default {
    static var sharedEntryText: Self {
        Self[.inMemory("sharedEntryText"), default: ""]
    }
}

extension SharedKey where Self == InMemoryKey<Bool>.Default {
    static var sharedEntryFocus: Self {
        Self[.inMemory("sharedEntryFocus"), default: false]
    }
}
