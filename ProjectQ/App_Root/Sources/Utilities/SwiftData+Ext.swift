
import SwiftUI
import SwiftData

extension ModelContext {
    func existingModel<T>(for objectID: PersistentIdentifier) throws -> T? where T: PersistentModel {
        if let registered: T = registeredModel(for: objectID) {
            return registered
        } else {
            let fetchDescriptor = FetchDescriptor<T>(
                predicate: #Predicate<T> {
                    $0.persistentModelID == objectID
                }
            )
            
            return try fetch(fetchDescriptor).first
        }
    }
}
