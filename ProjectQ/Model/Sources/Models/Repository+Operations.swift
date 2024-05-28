
import ComposableArchitecture

extension Entries: DependencyKey {
    public static var liveValue: Self = {
        Entries { operation, entry in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        } setLanguage: { entry, language in
            fatalError()
        } translations: { entry, operation, translation in
            fatalError()
        } moveTranslations: { fromOffsets, toOffset in
            fatalError()
        } keywords: { entry, operation, keyword in
            fatalError()
        } moveKeywords: { fromOffsets, toOffset in
            fatalError()
        } notes: { entry, operation, note in
            fatalError()
        } moveNotes: { fromOffsets, toOffset in
            fatalError()
        } usages: { entry, operation, usage in
            fatalError()
        } moveUsages: { fromOffsets, toOffset in
            fatalError()
        }
    }()
}

extension Keywords: DependencyKey {
    public static var liveValue: Self = {
        Keywords.init { operation, keyword in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        }
    }()
}

extension Languages: DependencyKey {
    public static var liveValue: Self = {
        Languages.init { operation, keyword in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        }
    }()
}

extension Notes: DependencyKey {
    public static var liveValue: Self = {
        Notes.init { operation, keyword in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        }
    }()
}

extension Usages: DependencyKey {
    public static var liveValue: Self = {
        Usages.init { operation, keyword in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        }
    }()
}

extension UserCollections: DependencyKey {
    public static var liveValue: Self = {
        UserCollections.init { operation, collection in
            switch operation {
            case .add: fatalError()
            case .remove: fatalError()
            }
        } entries: { userCollection, operation, entry in
            fatalError()
        } moveEntries: { fromOffsets, toOffset in
            fatalError()
        }
    }()
}
