
import ComposableArchitecture
import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        
        let container = try ModelContainer(for: Entry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                
        let entries = SampleData.entries()
        
        entries.forEach { entry in
            container.mainContext.insert(entry)
        }
        
        if let first = entries.first, let second = entries.dropFirst().first {
            first.translations.append(second)
        }

        return container
        
    } catch { fatalError("Failed to create container.") }
}()

struct SampleData {
    static func entries() -> [Entry] {
        (1...5).map {
            Entry.init(added: .now, modified: .now, spelling: "Entry \($0)")
        }
    }
}
