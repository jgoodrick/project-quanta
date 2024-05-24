
import ComposableArchitecture
import SwiftData
import SwiftUI

public enum ModelContainerKey: DependencyKey {
    public static var liveValue: ModelContainer = {
        do {
            return try ModelContainer(for: Entry.self, migrationPlan: .none)
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

extension ModelContainer {
    @MainActor
    func fetchLanguageBy(definition: Language.Definition, createIfMissing: Bool) throws -> Language {
        if let existing = try mainContext.fetch(FetchDescriptor(predicate: #Predicate<Language> { $0.definition.id == definition.id })).first {
            return existing
        } else if createIfMissing {
            
            let newLanguage = Language(definition: definition)
            
            mainContext.insert(newLanguage)
            
            try mainContext.save()
            
            return newLanguage
            
        } else {
            struct MissingExpectedLanguage: Error {
                let id: String
            }
            throw MissingExpectedLanguage(id: definition.id)
        }
    }
}

@DependencyClient
struct ActorContext: DependencyKey {
    static var testValue: ActorContext = .init()
    static var liveValue: ActorContext = .init(generate: {
        guard !Thread.isMainThread else {
            struct MainThreadAccessOfNonMainThreadActor: Error {}
            throw MainThreadAccessOfNonMainThreadActor()
        }
        @Dependency(\.modelContainer) var container
        return ContextActor(modelContainer: container)
    })
    var generate: () throws -> ContextActor
    func callAsFunction() throws -> ContextActor {
        try generate()
    }
}

extension DependencyValues {
    var actorContext: ActorContext {
        get { self[ActorContext.self] }
        set { self[ActorContext.self] = newValue }
    }
}

@ModelActor
public actor ContextActor {
    public func delete(_ model: some PersistentModel) async {
        modelContext.delete(model)
    }
    
    public func insert(_ model: some PersistentModel) async {
        modelContext.insert(model)
    }
    
    public func delete<T: PersistentModel>(
        where predicate: Predicate<T>?
    ) async throws {
        try modelContext.delete(model: T.self, where: predicate)
    }
    
    public func save() async throws {
        try modelContext.save()
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
        return try modelContext.fetch(descriptor)
    }
}


extension ContextActor {
    private func fetchLanguage(definition: Language.Definition, createIfMissing: Bool) async throws -> Language {
        if let existing = try modelContext.fetch(FetchDescriptor(predicate: #Predicate<Language> { $0.definition.id == definition.id })).first {
            return existing
        } else if createIfMissing {
            
            let newLanguage = Language(definition: definition)
            
            modelContext.insert(newLanguage)
            
            try modelContext.save()
            
            return newLanguage
            
        } else {
            struct MissingExpectedLanguage: Error {
                let id: String
            }
            throw MissingExpectedLanguage(id: definition.id)
        }
    }
    
    public func insertNewEntry(spelling: String, for definition: Language.Definition, createLanguageIfMissing: Bool = true) async throws -> Entry {
        
        let language = try await fetchLanguage(definition: definition, createIfMissing: createLanguageIfMissing)
        
        @Dependency(\.date) var date
        
        let now = date.now
        
        let newEntry = Entry(
            added: now,
            modified: now,
            language: language,
            spelling: spelling
        )
        
        modelContext.insert(newEntry)
        
        try modelContext.save()
        
        return newEntry
        
    }
    
}
