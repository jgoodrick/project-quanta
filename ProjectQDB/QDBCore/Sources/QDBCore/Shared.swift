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

    static var lastSelectedTranslationLanguageId: Self {
        @Dependency(\.defaultDatabase) var db
        @Shared(.languageId) var current
        let available = try? db.read { db in try DB.Language.Name.all.order(by: \.code).fetchAll(db) }
        return Self[.appStorage("lastSelectedTranslationLanguageId_from_\(current)"), default: available?.first?.code ?? "en"]
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
