
import ComposableArchitecture
import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        
        let container = try ModelContainer(for: Entry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let language = Language(definition: .bcp47("en_US"))
        
        container.mainContext.insert(language)
        
        let entries = SampleData.entries(language: language)
        
        entries.forEach { entry in
            container.mainContext.insert(entry)
        }
        
        if let first = entries.first, let second = entries.dropFirst().first {
            let translation = Translation(from: first, to: second, added: .now, modified: .now)
        }

        return container
        
    } catch { fatalError("Failed to create container.") }
}()

struct SampleData {
    static func entries(language: Language) -> [Entry] {
        (1...5).map {
            Entry.init(added: .now, modified: .now, language: language, spelling: "Entry \($0)")
        }
    }
}
