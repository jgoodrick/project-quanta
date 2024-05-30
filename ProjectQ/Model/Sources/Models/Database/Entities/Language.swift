
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Language: Identifiable, Equatable, Codable, Sendable {
    
    public init(bcp47: String) {
        // dashes are required in order for UITextField to parse and use it
        self.bcp47 = bcp47.replacingOccurrences(of: "_", with: "-")
    }
    
    public var id: String { bcp47 }
    
    public let bcp47: String
    var customLocalizedTitles: [String: String] = [:]
    
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        customLocalizedTitles.merge(with: incoming.customLocalizedTitles)
        metadata.merge(with: incoming.metadata)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: Set<Entry.ID> = []
        var usages: Set<Usage.ID> = []
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
            usages.merge(with: incoming.usages)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<Language>
        public let entries: [Entry]
        public let usages: [Usage]
        
        public var id: Language.ID { shared.wrappedValue.id }
    }
    
    // Convenience
        
    public var displayName: String {
        @Dependency(\.locale) var locale
        return customLocalizedTitles[locale.identifier] ?? locale.localizedString(forIdentifier: id) ?? id
    }
    
    public static var ukrainian: Language {
        .init(bcp47: "uk_UA")
    }
    public static var english: Language {
        .init(bcp47: "en_US")
    }
    
    var primaryLanguage: String? {
        parseComponent(at: 0)
    }
    
    var script: String? {
        guard tagComponents.count > 1 else { return nil }
        return isScriptComponent(at: 1) ? tagComponents[1] : nil
    }
    
    var region: String? {
        guard tagComponents.count > 1 else { return nil }
        return isRegionComponent(at: tagComponents.count - 1) ? tagComponents[tagComponents.count - 1] : nil
    }
    
    var variant: String? {
        guard tagComponents.count > 2 else { return nil }
        let startIndex = isScriptComponent(at: 1) ? 2 : 1
        let endIndex = isRegionComponent(at: tagComponents.count - 1) ? tagComponents.count - 2 : tagComponents.count - 1
        return startIndex <= endIndex ? tagComponents[startIndex] : nil
    }
    
    var extensions: [String] {
        return tagComponents.filter { $0.starts(with: "u-") }
    }
    
    var privateUse: String? {
        return tagComponents.first(where: { $0.starts(with: "x-") })
    }
    
    private var tagComponents: [String] {
        return bcp47.split(separator: "-").map(String.init)
    }
    
    private func parseComponent(at index: Int) -> String? {
        return tagComponents.indices.contains(index) ? tagComponents[index] : nil
    }
    
    private func isScriptComponent(at index: Int) -> Bool {
        guard tagComponents.indices.contains(index) else { return false }
        return tagComponents[index].count == 4 && tagComponents[index].allSatisfy({ $0.isLetter })
    }
    
    private func isRegionComponent(at index: Int) -> Bool {
        guard tagComponents.indices.contains(index) else { return false }
        let component = tagComponents[index]
        return (component.count == 2 && component.allSatisfy({ $0.isLetter })) ||
               (component.count == 3 && component.allSatisfy({ $0.isNumber }))
    }

}
