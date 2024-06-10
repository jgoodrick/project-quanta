
import ComposableArchitecture
import FeatureCore
import Foundation
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct EntryTranslationsEditor {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var textField: ToolbarTextField.State = .init()
        
        @Presents var destination: Destination.State?
        
        var translations: [Entry] {
            db.translations(forEntry: entryID)
        }
        
        mutating func setToSystemLanguage() {
            @Dependency(\.systemLanguages) var systemLanguages
            textField.languageOverride = systemLanguages.current().id
        }

        mutating func submitCurrentFieldValueAsTranslation() -> EffectOf<EntryTranslationsEditor> {
            defer { textField.reset() }
            let translationSpelling = textField.text
            guard !translationSpelling.isEmpty else { return .none }
            let matches = db.entries(where: { $0.spelling == translationSpelling })
            if let first = matches.first {
                
                if matches.count > 1 {
                    
                    // TODO: handle more than one match
                    // delegate to the confirmation dialog to get a decision from the user

                    destination = .alert(.init(title: { .init("There was more than one entry that matched that translation's spelling. This is not currently supported.")}))
                    
                } else {
                    db.connect(translation: first.id, toEntry: entryID)
                }

            } else {
                
                let translationLanguage = textField.language
                
                let newEntry = db.createNewEntry(language: translationLanguage) {
                    $0.spelling = translationSpelling
                }
                
                db.connect(translation: newEntry.id, toEntry: entryID)

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
        case addTranslationAsExistingEntry(Entry)
        case addTranslationAsNewEntry
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case textField(ToolbarTextField.Action)
        
        case task
        case addButtonTapped
        case addLongPressMenuButtonTapped(Language)
        case destructiveSwipeButtonTapped(Entry)
        case moved(fromOffsets: IndexSet, toOffset: Int)
        
        case delegate(Delegate)
        public enum Delegate {
            case selected(Entry)
        }
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.textField, action: \.textField) {
            ToolbarTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate: return .none
            case .binding: return .none
            case .destination: return .none
                
            case .task:
                
                state.setToSystemLanguage()
                
                return .none
                
            case .addButtonTapped:

                state.setToSystemLanguage()
                state.textField.collapsed = false
                
                return .none

            case .addLongPressMenuButtonTapped(let selected):

                state.textField.languageOverride = selected.id
                state.textField.collapsed = false

                return .none

            case .textField(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: 
                    return state.submitCurrentFieldValueAsTranslation()
                }
            case .textField: return .none
                
            case .destructiveSwipeButtonTapped(let translation):

                state.db.disconnect(translation: translation.id, fromEntry: state.entryID)
                
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
    static func addOrUseExisting(entry: Entry) -> Self where Action == EntryTranslationsEditor.ConfirmationDialog {
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

extension Entry: CategorizedItem {
    public var value: String { spelling }
}

struct EntryTranslationsEditorView: View {
    
    @Bindable var store: StoreOf<EntryTranslationsEditor>
    
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
        .task { await store.send(.task).finish() }
    }
}
