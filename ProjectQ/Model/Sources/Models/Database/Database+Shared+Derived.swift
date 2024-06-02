
import ComposableArchitecture

extension Shared<Database> {
    
    public mutating func languageOf(entry: Entry.ID) -> Shared<Language.ID?> {
        precondition(wrappedValue.stored.entries[entry] != nil)
        return projectedValue.relationships.entries[id: entry].language
    }
    
}
