
extension Database {
    
    public mutating func ensureExistenceOf(language: Language, mergeIfExists: Bool = true) throws {
        if stored.languages[language.id] == nil {
            add(language: language)
        } else if mergeIfExists {
            stored.languages[language.id, default: language].merge(with: language)
        }
    }
    
}
