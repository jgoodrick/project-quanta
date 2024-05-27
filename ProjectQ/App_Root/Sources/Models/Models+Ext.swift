
import ComposableArchitecture
import SwiftUI

extension Entry {
    static func empty() -> Self {
        @Dependency(\.date.now) var now
        return self.init(added: now, modified: now, spelling: "")
    }
    func update<T>(keyPath: ReferenceWritableKeyPath<Entry, T>, to value: T) {
        self[keyPath: keyPath] = value
        @Dependency(\.date.now) var now
        modified = now
    }
}

extension Usage {
    static func empty() -> Self {
        @Dependency(\.date.now) var now
        return self.init(added: now, modified: now, value: "")
    }
    func update<T>(keyPath: ReferenceWritableKeyPath<Usage, T>, to value: T) {
        self[keyPath: keyPath] = value
        @Dependency(\.date.now) var now
        modified = now
        // TODO - if .value was changd, consider checking for existing now-matching entries to add
    }
}

extension Language {
    public var displayName: String {
        definition.id
//        definition.displayName
    }
    public var locale: Locale? {
        switch definition {
        case .bcp47(let identifier): Locale(identifier: identifier)
        case .custom: .none
        }
    }
}
