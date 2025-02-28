
import Foundation

extension DB.Language {

    var uiTextFieldParsableID: String? {
        struct AttemptedToCreateLanguageWithEmptyLanguageCode: Error {}
        guard let keyboardID, !keyboardID.isEmpty else {
            // Language Found With Empty Language Code
            return nil
        }
        // dashes are required in order for UITextField to parse and use it
        return keyboardID.replacingOccurrences(of: "_", with: "-")
    }

    public static var ukrainian: Self {
        .init(keyboardID: "uk_UA")
    }

    public static var english: Self {
        .init(keyboardID: "en_US")
    }

    public static var spanish: Self {
        .init(keyboardID: "es_MX")
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
        keyboardID?.split(separator: "-").map(String.init) ?? []
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
