
import SwiftUI

extension EntryDetailStore {
        
    var populatedContextSections: [ContextSection] {
        ContextSection.allCases.filter {
            switch $0 {
            case .tags:
                !self.tags.isEmpty
            case .translations:
                !self.translations.isEmpty
            case .examples:
                !self.examples.isEmpty
            case .notes:
                !self.notes.isEmpty
            case .collections:
                !self.collectionsMembership.isEmpty
            case .relatedEntries:
                !self.relatedEntries.isEmpty
            }
        }
    }

    var unpopulatedContextSections: [ContextSection] {
        ContextSection.unpopulatedSuggestions.filter {
            switch $0 {
            case .tags:
                self.tags.isEmpty
            case .translations:
                self.translations.isEmpty
            case .examples:
                self.examples.isEmpty
            case .notes:
                self.notes.isEmpty
            case .collections:
                self.collectionsMembership.isEmpty
            case .relatedEntries:
                self.relatedEntries.isEmpty
            }
        }
    }
    
    var unpopulatedAdditionalContext: [AdditionalContext] {
        AdditionalContext.allCases.filter {
            switch $0 {
            case .pronunciation:
                self.pronunciation == nil
            case .image:
                self.image == nil
            }
        }
    }

}

struct EntryDetailPopulatedSection: View {
    let store: EntryDetailStore
    var body: some View {
        ForEach(store.populatedContextSections) {
            switch $0 {
            case .tags:
                EntryDetailTagsSection(store: store)
            case .translations:
                EntryDetailTranslationsSection(store: store)
            case .examples:
                EntryDetailExamplesSection(store: store)
            case .notes:
                EntryDetailNotesSection(store: store)
            case .collections:
                EntryDetailCollectionsMembershipSection(store: store)
            case .relatedEntries:
                EntryDetailRelatedEntriesSection(store: store)
            }
        }
    }
}

struct EntryDetailUnpopulatedSection: View {
    let store: EntryDetailStore
    var body: some View {
        ForEach(store.unpopulatedContextSections) {
            switch $0 {
            case .tags:
                AddFirstTagButton(store: store)
            case .translations:
                AddFirstTranslationsButton(store: store)
            case .examples:
                AddFirstExamplesButton(store: store)
            case .notes:
                AddFirstNotesButton(store: store)
            case .collections:
                AddFirstCollectionMembershipButton(store: store)
            case .relatedEntries:
                AddFirstRelatedEntriesButton(store: store)
            }
        }
    }
}

struct EntryDetailUnpopulatedAdditionalContext: View {
    let store: EntryDetailStore
    var body: some View {
        ForEach(store.unpopulatedAdditionalContext) {
            switch $0 {
            case .pronunciation:
                PronunciationButton(store: store)
            case .image:
                SplashImageButton(store: store)
            }
        }
    }
}

