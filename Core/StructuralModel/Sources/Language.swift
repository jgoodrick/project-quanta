
import Foundation

public struct Language: Identifiable, Equatable, Codable, Sendable {
    public init(bcp47: String) throws {
        struct AttemptedToCreateLanguageWithEmptyLanguageCode: Error {}
        guard !bcp47.isEmpty else { throw AttemptedToCreateLanguageWithEmptyLanguageCode() }
        // dashes are required in order for UITextField to parse and use it
        self.bcp47 = .init(rawValue: bcp47.replacingOccurrences(of: "_", with: "-"))
    }

    public var id: TaggedString<BCP47> { bcp47 }
    
    public let bcp47: ID
    
    public enum BCP47 {}
    
}

extension TaggedString<Language.BCP47> {
    public var entityID: Entity.ID {
        .language(self)
    }
}

extension Language {
    
    public static var ukrainian: Language {
        try! .init(bcp47: "uk_UA")
    }
    public static var english: Language {
        try! .init(bcp47: "en_US")
    }
    public static var spanish: Language {
        try! .init(bcp47: "es_MX")
    }
    
    public var primaryLanguage: String? {
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
        tagComponents.filter { $0.starts(with: "u-") }
    }
    
    var privateUse: String? {
        tagComponents.first(where: { $0.starts(with: "x-") })
    }
    
    private var tagComponents: [String] {
        bcp47.rawValue.split(separator: "-").map(String.init)
    }
    
    private func parseComponent(at index: Int) -> String? {
        tagComponents.indices.contains(index) ? tagComponents[index] : nil
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
