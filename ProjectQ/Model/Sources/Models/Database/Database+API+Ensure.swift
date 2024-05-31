
extension Database {
    
    public mutating func ensureExistenceOf(language: Language) throws {
        if stored.languages[language.id] == nil {
            add(language: language)
        }
    }
    
}
