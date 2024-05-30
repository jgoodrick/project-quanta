
import ComposableArchitecture

extension Database {
    
    public mutating func seedWithSystemValues() {
        @Dependency(\.systemLanguages) var systemLanguages
        systemLanguages.inDefaultSortOrder.forEach {
            stored.languages[$0.id] = $0
        }
        stored.users.values.forEach { user in
            if relationships.users[id: user.id].languages.isEmpty {
                relationships.users[id: user.id].languages = systemLanguages.inDefaultSortOrder.map(\.id)
            }
        }
    }
    
}

