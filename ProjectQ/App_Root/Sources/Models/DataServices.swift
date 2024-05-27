
import ComposableArchitecture
import SwiftData
import SwiftUI

public enum ModelContainerKey: DependencyKey {
    public static var liveValue: ModelContainer = {
        do {
            return try ModelContainer(for: Entry.self, migrationPlan: .none, configurations: .init(isStoredInMemoryOnly: true))
        } catch {
            fatalError("Failed to initialize the model container")
        }
    }()
}

extension DependencyValues {
    public var modelContainer: ModelContainer {
        get { self[ModelContainerKey.self] }
        set { self[ModelContainerKey.self] = newValue }
    }
}

@DependencyClient
public struct AppModelActorGenerator: DependencyKey {
    public static var liveValue: AppModelActorGenerator = .init()
    public var generate: () -> AppModelActor = {
        @Dependency(\.modelContainer) var modelContainer
        return AppModelActor(modelContainer: modelContainer)
    }
    public func callAsFunction() -> AppModelActor {
        generate()
    }
}

extension DependencyValues {
    public var appModelActor: AppModelActorGenerator {
        get { self[AppModelActorGenerator.self] }
        set { self[AppModelActorGenerator.self] = newValue }
    }
}

@ModelActor
public actor AppModelActor {}

extension ModelContext {
    
    public func language(for definition: Language.Definition, createIfMissing: Bool = false) -> Language? {
        try? fetchLanguage(definition: definition, createIfMissing: createIfMissing)
    }

    public func fetchLanguage(definition: Language.Definition, createIfMissing: Bool) throws -> Language {
        if let existing = try fetch(FetchDescriptor(predicate: #Predicate<Language> { $0.definitionID == definition.id })).first {
            return existing
        } else if createIfMissing {
            
            let newLanguage = Language(definition: definition)
            
            insert(newLanguage)
            
            try save()
            
            @Shared(.languageSelectionList) var languageSelectionList
            
            languageSelectionList.append(newLanguage.definition)
            
            return newLanguage
            
        } else {
            struct MissingExpectedLanguage: Error {
                let id: String
            }
            throw MissingExpectedLanguage(id: definition.id)
        }
    }
    
    public func insertNewEntry(spelling: String) throws -> Entry {
                
        @Dependency(\.date) var date
        
        let now = date.now
        
        let newEntry = Entry(
            added: now,
            modified: now,
            spelling: spelling
        )
        
        insert(newEntry)
                
        try save()
        
        return newEntry
        
    }
    
}
