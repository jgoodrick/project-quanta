

import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryUsagesEditor {
    
    @ObservableState
    public struct State: Equatable {
        
        init(entryID: Shared<Entry.ID>) {
            self._entryID = entryID
            @Shared(.db) var database
            self.tracking = .init(
                languageID: $database.languageOf(entry: entryID.wrappedValue)
            )
        }

        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var tracking: LanguageTrackingFloatingTextField.State

        @Presents var destination: Destination.State?
        
        var usages: [Usage.Expansion] {
            $db.usages(for: entryID)
        }

        mutating func submitCurrentFieldValueAsUsage() -> EffectOf<EntryUsagesEditor> {
            
            defer {
                tracking.textField.reset()
            }

            let value = tracking.textField.text
            
            guard !value.isEmpty else {
                return .none
            }
            
            let matches = $db.usages(where: \.value, is: value)
            
            if let first = matches.first {
                
                if matches.count > 1 {
                    
                    // what if there are more than one words in the repo that match the spelling of the usage the user just typed in? (Because the user previously decided to create a separate word with the same spelling instead of merging or editing the existing one). We will need to handle this with a confirmation dialog, as we have done previously.
                    // TODO: handle more than one match
                    
                    // Note, this is where we would delegate to the confirmation dialog to get a decision from the user about which one to use, or whether to create a new one
                    
                    destination = .alert(.init(title: { .init("There was more than one entry that matched that usage's. This is not currently supported.")}))
                    
                } else {
                    
                    db.connect(usage: first.id, to: entryID)

                }

            } else {
                
                do {
                    
                    let value = tracking.textField.text
                    let valueLanguage = tracking.textField.language
                    
                    let newUsage = try $db.addNewUsage(language: valueLanguage) {
                        $0.value = value
                    }
                    
                    db.connect(usage: newUsage.id, to: entryID)
                    
                } catch {
                    
                    destination = .alert(.init(title: { .init("Failed to add a new usage: \(error.localizedDescription)") }))
                    
                }
                
            }
                                            
            return .none

        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryUsagesEditor.ConfirmationDialog>)
    }
    
    public enum ConfirmationDialog: Equatable {
        case cancel
        case addUsageAsExistingEntry(Entry.Expansion)
        case addUsageAsNewEntry
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case tracking(LanguageTrackingFloatingTextField.Action)
        
        case addButtonTapped
        case addLongPressMenuButtonTapped(Language)
        case destructiveSwipeButtonTapped(Usage.Expansion)
        case moved(fromOffsets: IndexSet, toOffset: Int)
        
        case delegate(Delegate)
        public enum Delegate {
            case usageSelected(Usage.Expansion)
        }
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.tracking, action: \.tracking) {
            LanguageTrackingFloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate: return .none
            case .binding: return .none
            case .destination: return .none

            case .addButtonTapped:

                @Dependency(\.systemLanguages) var systemLanguages

                state.tracking.textField.languageOverride = systemLanguages.current().id
                state.tracking.textField.collapsed = false
                
                return .none

            case .addLongPressMenuButtonTapped(let selected):

                state.tracking.textField.languageOverride = selected.id
                state.tracking.textField.collapsed = false

                return .none

            case .tracking(.textField(.delegate(let delegatedAction))):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: return state.submitCurrentFieldValueAsUsage()
                }
            case .tracking: return .none
            case .destructiveSwipeButtonTapped(let translation):

                state.db.remove(translation: translation.id, from: state.entryID)
                
                return .none

            case .moved(let fromOffsets, let toOffset):

                state.db.moveUsages(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrUseExisting(entry: Entry.Expansion) -> Self where Action == EntryUsagesEditor.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .addUsageAsNewEntry, label: { .init("Create new entry") }
                )
                ButtonState<Action>.init(
                    action: .addUsageAsExistingEntry(entry), label: { .init("Use existing") }
                )
            },
            message: {
                .init("Would you like to use it or create a new entry with the same spelling?")
            }
        )
    }
}

struct EntryUsagesEditorView: View {
    
    @SwiftUI.Bindable var store: StoreOf<EntryUsagesEditor>
    
    var body: some View {
        Section {
            ForEach(store.usages) { usage in
                HStack {
                    Button(action: { store.send(.delegate(.usageSelected(usage))) }) {
                        Text("\(usage.value)")
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.destructiveSwipeButtonTapped(usage))
                        },
                        label: {
                            Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                        }
                    )
                }
            }
            .onMove { from, to in
                store.send(.moved(fromOffsets: from, toOffset: to))
            }

        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Usages")
                
                Spacer()
                
                Menu(content: {
                    // long press
                    ForEach(store.settings.languageSelectionList) { menuItem in
                        Button(action: {
                            store.send(.addLongPressMenuButtonTapped(menuItem))
                        }) {
                            Label(menuItem.displayName.capitalized, systemImage: "flag")
                        }
                    }
                }, label: {
                    Text("+ Add")
                        .font(.callout)
                        .textCase(.lowercase)
                }, primaryAction: {
                    // on tap
                    store.send(.addButtonTapped)
                })
            }
        }
    }
}

