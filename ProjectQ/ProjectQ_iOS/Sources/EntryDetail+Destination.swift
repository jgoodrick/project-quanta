
import AppModel
import ComposableArchitecture
import StructuralModel
import SwiftUI

extension EntryDetail {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case keyboardUnavailable(AlertState<Never>)
        case emptyUsageResolution(AlertState<EmptyUsageResolution>)
        case emptyNoteResolution(AlertState<EmptyNoteResolution>)
        case orphanedIfRemoved(AlertState<OrphanedIfRemovedResolution>)
        
        case spellingUpdateConflict(ConfirmationDialogState<SpellingConflictResolution>)
        case newTranslationSpellingConflict(ConfirmationDialogState<NewTranslationSpellingConflictResolution>)
    }
    
    public struct OrphanedIfRemovedResolution: Equatable {
        let target: RemovalTarget
        let decision: Decision
        public enum Decision: Equatable {
            case cancel
            case delete
            case disconnectOnly
        }
    }
    
    enum RemovalTarget: Equatable {
        case translation(Entry)
        case usage(Usage)
        case note(Note)
        // case seeAlso(Entry)
        // case root(Entry)
        // case derived(Entry)
        var entity: Entity {
            switch self {
            case .translation(let entry): .entry(entry)
            case .usage(let usage): .usage(usage)
            case .note(let note): .note(note)
            }
        }
    }

    public enum UnavailableKeyboardResolution: Equatable {
        case cancel
        case goToKeyboardSettings
    }
    
    public struct SpellingConflictResolution: Equatable {
        let firstMatch: Entry
        let decision: AppModel.AutoConflictResolution
    }
    
    public struct NewTranslationSpellingConflictResolution: Equatable {
        let firstMatch: Entry
        let decision: AppModel.AutoConflictResolution
    }
    
    public enum EmptyUsageResolution: Equatable {
        case cancel
        case delete(Usage.ID)
    }

    public enum EmptyNoteResolution: Equatable {
        case cancel
        case delete(Note.ID)
    }


}

extension EntryDetail.State {
    
    enum ToolbarTarget: Equatable {
        case spelling
        case newTranslation
        case usage(Usage.ID?)
        case note(Note.ID?)
    }
        
    var languages: [Language] {
        model.languages(.of(.entry(entryID)))
    }
    
    var availableLanguages: [Language] {
        model.settings.languageSelectionList.map({ $0 })
    }

    var entry: Entry? {
        model[entry: entryID]
    }

    var translations: [Entry] {
        model.entries(.thatAre(.translations(of: entryID)))
    }

    var usages: [Usage] {
        model.usages(.of(.entry(entryID)))
    }

    var notes: [Note] {
        model.notes(.of(.entry(entryID)))
    }

    var systemLanguage: Language {
        @Dependency(\.systemLanguages) var systemLanguages
        return systemLanguages.current()
    }

    mutating func resetToolbarTextField(to targeting: ToolbarTarget? = nil, languageOverride: Language? = nil) {
        switch targeting {
        case .spelling:
            textField.placeholder = "Provide the spelling"
            textField.text = entry?.spelling ?? ""
            textField.languageOverride = languages.first
            textField.autocapitalization = .none

        case .newTranslation:
            let targetLanguage = languageOverride ?? systemLanguage
            textField.placeholder = "Add a \(model.displayName(for: targetLanguage)) translation"
            textField.text = ""
            textField.languageOverride = targetLanguage
            textField.autocapitalization = .none

        case .usage(let id):
            textField.placeholder = "Add an example sentence"
            textField.text = id.flatMap({ model[usage: $0]?.value }) ?? ""
            textField.languageOverride = systemLanguage
            textField.autocapitalization = .sentences

        case .note(let id):
            textField.placeholder = "Add a note about this word"
            textField.text = id.flatMap({ model[note: $0]?.value }) ?? ""
            textField.languageOverride = systemLanguage
            textField.autocapitalization = .sentences

        case nil:
            textField.text = ""
            textField.languageOverride = systemLanguage
            textField.autocapitalization = .none
        }
        textField.languageOverride = languageOverride
        textField.target = targeting
    }
    
    mutating func resolveEmptyTextSubmission() -> EffectOf<EntryDetail> {
        switch textField.target {
        case .none, .spelling, .newTranslation: break
        case .usage(let id):
            if let id {
                destination = .emptyUsageResolution(.emptyUsageResolution(id: id))
            }
        case .note(let id):
            if let id {
                destination = .emptyNoteResolution(.emptyNoteResolution(id: id))
            }
        }
        return .none
    }

    mutating func submitText() -> EffectOf<EntryDetail> {
        
        defer {
            resetToolbarTextField()
        }
        
        guard !textField.text.isEmpty else {
            return resolveEmptyTextSubmission()
        }

        switch textField.target {
        case .spelling:
            switch model.attemptToUpdateEntrySpelling(of: entryID, to: textField.text) {
            case .success, .canceled: break
            case .conflicts(let conflicts):
                destination = .spellingUpdateConflict(.spellingUpdateMatches(entries: conflicts))
            }
        case .newTranslation:
            switch model.attemptToAddNewTranslation(fromSpelling: textField.text, forEntry: entryID) {
            case .success, .canceled: break
            case .conflicts(let conflicts):
                destination = .newTranslationSpellingConflict(.newTranslationSpellingMatches(entries: conflicts))
            }
        case .usage(let id):

            if let id {
                model.updateUsage(\.value, of: id, to: textField.text)
            } else if !textField.text.isEmpty {
                _ = model.attemptToAddNewUsage(content: textField.text, toEntry: entryID, autoAppliedValueConflictResolution: .mergeWithFirstMatch)
            }
            
        case .note(let id):
            if let id {
                model.updateNote(\.value, of: id, to: textField.text)
            } else if !textField.text.isEmpty {
                _ = model.attemptToAddNewNote(content: textField.text, toEntry: entryID)
            }

        case nil:
            preconditionFailure("toolbar target not set when 'submitText()' was called")
        }
        
        return .none
        
    }
    
    mutating func resolveSpellingUpdateConflict(resolution: EntryDetail.SpellingConflictResolution) {
        
        let result = model.attemptToUpdateEntrySpelling(
            of: entryID,
            to: resolution.firstMatch.spelling,
            autoAppliedSpellingConflictResolution: resolution.decision
        )
        
        switch result {
        case .canceled: break
        case .conflicts(let conflicts): XCTFail("Unexpected behavior of AppModel.attemptToUpdateEntrySpelling() \(conflicts)")
        case .success(let merged):
            // update the detail page to represent the first match, as the current entry has been deleted during merge:
            entryID = merged.id
        }

    }
    
    mutating func resolveTranslationSpellingConflict(resolution: EntryDetail.NewTranslationSpellingConflictResolution) {
        
        let result = model.attemptToAddNewTranslation(
            fromSpelling: resolution.firstMatch.spelling,
            in: textField.languageOverride?.id,
            forEntry: entryID,
            autoAppliedSpellingConflictResolution: resolution.decision
        )
        
        switch result {
        case .canceled, .success: break
        case .conflicts(let conflicts): XCTFail("Unexpected behavior of AppModel.attemptToAddNewTranslation() \(conflicts)")
        }

    }
    
    mutating func resolveOrphanedIfRemoved(resolution: EntryDetail.OrphanedIfRemovedResolution) {
        
        switch resolution.decision {
        case .cancel: break
        case .delete: model.delete(resolution.target.entity.id)
        case .disconnectOnly:
            switch resolution.target {
            case .translation(let translation):
                model.remove(translation: translation.id, fromEntry: entryID)
            case .usage(let usage):
                model.remove(usage: usage.id, fromEntry: entryID)
            case .note(let note):
                model.remove(note: note.id, fromEntry: entryID)
            }
        }

    }
}

fileprivate extension EntryDetail.RemovalTarget {
    var confirmationTitle: String {
        switch self {
        case .translation(let entry): entry.spelling
        case .note(let note):
            "\(note.value.prefix(15))\(note.value.count > 15 ? "..." : "")"
        case .usage(let usage):
            "\(usage.value.prefix(15))\(usage.value.count > 15 ? "..." : "")"
        }
    }
}

extension AlertState {
    static func directUserToSettingsToSetUpKeyboard() -> Self where Action == Never {
        .init(
            title: {
                .init("The keyboard for that language is unavailable")
            },
            message: {
                .init("If you would like to add a keyboard to support it, please go to 'Settings > General > Keyboard > Keyboards' and add one there. Or, you can long-press on the language switcher at the bottom left of your keyboard.")
            }
        )
    }
    static func emptyUsageResolution(id: Usage.ID) -> Self where Action == EntryDetail.EmptyUsageResolution {
        .init(
            title: {
                .init("Examples cannot be empty, would you like to delete it?")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .delete(id), label: { .init("Delete") }
                )
            }
        )
    }
    static func emptyNoteResolution(id: Note.ID) -> Self where Action == EntryDetail.EmptyNoteResolution {
        .init(
            title: {
                .init("Notes cannot be empty, would you like to delete it?")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .delete(id), label: { .init("Delete") }
                )
            }
        )
    }
    static func confirmDeletion(of target: EntryDetail.RemovalTarget) -> Self where Action == EntryDetail.OrphanedIfRemovedResolution {
        .init(
            title: {
                .init("Delete '\(target.confirmationTitle)'?")
            },
            actions: {
                ButtonState<Action>.init(
                    role: .destructive, action: .init(target: target, decision: .delete), label: { .init("Delete") }
                )
                ButtonState<Action>.init(
                    action: .init(target: target, decision: .disconnectOnly), label: { .init("Disconnect Only") }
                )
                ButtonState<Action>.init(
                    role: .cancel, action: .init(target: target, decision: .cancel), label: { .init("Cancel") }
                )
            }
        )
    }
}

extension ConfirmationDialogState {
    static func spellingUpdateMatches(entries: [Entry]) -> Self where Action == EntryDetail.SpellingConflictResolution {
        guard let firstMatch = entries.first else { preconditionFailure() }
        return .init(
            title: {
                .init("A word spelled \"\(firstMatch.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .cancel), label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .maintainDistinction), label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .mergeWithFirstMatch), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
    static func newTranslationSpellingMatches(entries: [Entry]) -> Self where Action == EntryDetail.NewTranslationSpellingConflictResolution {
        guard let firstMatch = entries.first else { preconditionFailure() }
        return .init(
            title: {
                .init("A word spelled \"\(firstMatch.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .cancel), label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .maintainDistinction), label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .mergeWithFirstMatch), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
}

