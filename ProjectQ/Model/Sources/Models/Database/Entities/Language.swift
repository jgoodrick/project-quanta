
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Language: Identifiable, Equatable, Codable, Sendable {
    
    struct AttemptedToCreateLanguageWithEmptyLanguageCode: Error {}

    public init(bcp47: String) throws {
        guard !bcp47.isEmpty else { throw AttemptedToCreateLanguageWithEmptyLanguageCode() }
        // dashes are required in order for UITextField to parse and use it
        self.bcp47 = bcp47.replacingOccurrences(of: "_", with: "-")
    }
    
    public var id: String { bcp47 }
    
    public let bcp47: String
    public var customNameForAllLanguages: String?
    public var customLocalizedNames: [String: String] = [:]
    
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        customLocalizedNames.merge(with: incoming.customLocalizedNames)
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
    
    // MARK: - Conveniences
    
    public var displayName: String {
        @Dependency(\.locale) var locale
        if let custom = customNameForAllLanguages ?? customLocalizedNames[locale.identifier] {
            return custom
        } else {
            // we only want to show the additional (region) information if the primary language is not unique
            @Shared(.settings) var settings
            var copy = settings.languageSelectionList
            copy[id: id] = nil
            if copy.contains(where: { $0.primaryLanguage == primaryLanguage }) {
                return locale.localizedString(forIdentifier: bcp47) ?? id
            } else {
                return primaryLanguage.flatMap({ locale.localizedString(forLanguageCode: $0) }) ?? id
            }
        }
    }
    
    public static var ukrainian: Language {
        try! .init(bcp47: "uk_UA")
    }
    public static var english: Language {
        try! .init(bcp47: "en_US")
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
