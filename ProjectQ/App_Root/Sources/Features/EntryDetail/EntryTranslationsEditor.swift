
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryTranslationsEditor {
    
    @ObservableState
    public struct State: Equatable {
                
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var textField: FloatingTextField.State = {
            @Dependency(\.systemLanguages) var systemLanguages
            let system = systemLanguages.current()
            return .init(languageOverride: system.id)
        }()
        
        @Presents var destination: Destination.State?
        
        var translations: [Entry.Expansion] {
            $db.translations(for: entryID)
        }

        mutating func submitCurrentFieldValueAsTranslation() -> EffectOf<EntryTranslationsEditor> {
            
            defer {
                textField.reset()
            }

            let translationSpelling = textField.text
            
            guard !translationSpelling.isEmpty else {
                return .none
            }
            
            let matches = $db.entries(where: \.spelling, is: translationSpelling)
            
            if let first = matches.first {
                
                if matches.count > 1 {
                    
                    // what if there are more than one words in the repo that match the spelling of the translation the user just typed in? (Because the user previously decided to create a separate word with the same spelling instead of merging or editing the existing one). We will need to handle this with a confirmation dialog, as we have done previously.
                    // TODO: handle more than one match
                    
                    // Note, this is where we would delegate to the confirmation dialog to get a decision from the user about which one to use, or whether to create a new one
                    
                    destination = .alert(.init(title: { .init("There was more than one entry that matched that translation's spelling. This is not currently supported.")}))
                    
                } else {
                    
                    db.connect(translation: first.id, to: entryID)

                }

            } else {
                
                do {
                    
                    let translationSpelling = textField.text
                    let translationLanguage = textField.language
                    
                    let newEntry = try $db.addNewEntry(language: translationLanguage) {
                        $0.spelling = translationSpelling
                    }
                    
                    db.connect(translation: newEntry.id, to: entryID)
                    
                } catch {
                    
                    destination = .alert(.init(title: { .init("Failed to add a new translation: \(error.localizedDescription)") }))
                    
                }
                
            }
                                            
            return .none

        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryTranslationsEditor.ConfirmationDialog>)
    }
    
    public enum ConfirmationDialog: Equatable {
        case cancel
        case addTranslationAsExistingEntry(Entry.Expansion)
        case addTranslationAsNewEntry
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case textField(FloatingTextField.Action)
        
        case addButtonTapped
        case addLongPressMenuButtonTapped(Language)
        case destructiveSwipeButtonTapped(Entry.Expansion)
        case moved(fromOffsets: IndexSet, toOffset: Int)
        
        case delegate(Delegate)
        public enum Delegate {
            case selected(Entry.Expansion)
        }
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.textField, action: \.textField) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate: return .none
            case .binding: return .none
            case .destination: return .none

            case .addButtonTapped:

                @Dependency(\.systemLanguages) var systemLanguages

                state.textField.languageOverride = systemLanguages.current().id
                state.textField.collapsed = false
                
                return .none

            case .addLongPressMenuButtonTapped(let selected):

                state.textField.languageOverride = selected.id
                state.textField.collapsed = false

                return .none

            case .textField(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: return state.submitCurrentFieldValueAsTranslation()
                }
            case .textField: return .none
            case .destructiveSwipeButtonTapped(let translation):

                state.db.remove(translation: translation.id, from: state.entryID)
                
                return .none

            case .moved(let fromOffsets, let toOffset):

                state.db.moveTranslations(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrUseExisting(entry: Entry.Expansion) -> Self where Action == EntryTranslationsEditor.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .addTranslationAsNewEntry, label: { .init("Create new entry") }
                )
                ButtonState<Action>.init(
                    action: .addTranslationAsExistingEntry(entry), label: { .init("Use existing") }
                )
            },
            message: {
                .init("Would you like to use it or create a new entry with the same spelling?")
            }
        )
    }
}

extension Entry.Expansion: CategorizedItem {
    var value: String { spelling }
}

struct EntryTranslationsEditorView: View {
    
    @SwiftUI.Bindable var store: StoreOf<EntryTranslationsEditor>
    
    var body: some View {
        CategorizedItemsSection(
            title: "Translations",
            items: store.translations,
            availableCategories: store.settings.languageSelectionList.map({ $0 }),
            onSelected: { store.send(.delegate(.selected($0))) },
            onDeleted: { store.send(.destructiveSwipeButtonTapped($0)) },
            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
            onMenuItemTapped: { store.send(.addLongPressMenuButtonTapped($0)) },
            onMenuShortPressed: { store.send(.addButtonTapped) }
        )
    }
}
