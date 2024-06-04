
import ComposableArchitecture

extension Shared<Database> {
    
    public mutating func languagesOf(entry: Entry.ID) -> Shared<[Language.ID]> {
        precondition(wrappedValue.stored.entries[entry] != nil)
        return projectedValue.relationships.entries[id: entry].languages
    }
    
}
