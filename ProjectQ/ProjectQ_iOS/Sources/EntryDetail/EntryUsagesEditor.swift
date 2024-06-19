//
//import AppModel
//import ComposableArchitecture
//import Foundation
//import LayoutCore
//import StructuralModel
//import SwiftUI
//
//@Reducer
//public struct EntryUsagesEditor {
//    
//    @ObservableState
//    public struct State: Equatable {
//        
//        init(entryID: Shared<Entry.ID>) {
//            self._entryID = entryID
//            self.textField = .init(matching: .entry(entryID.wrappedValue))
//        }
//
//        @Shared(.db) var db
//        @Shared(.settings) var settings
//        
//        @Shared var entryID: Entry.ID
//        var textField: ToolbarTextField.State
//
//        @Presents var destination: Destination.State?
//        
//        var usages: [Usage] {
//            db.usages(forEntry: entryID)
//        }
//        
//        mutating func submitCurrentFieldValueAsUsage() -> EffectOf<EntryUsagesEditor> {
//            defer { textField.reset() }
//            let value = textField.text
//            guard !value.isEmpty else { return .none }
//            let matches = db.usages(where: { $0.value == value})
//            if let first = matches.first {
//                
//                if matches.count > 1 {
//                    
//                    // TODO: handle more than one match
//                    // delegate to the confirmation dialog to get a decision from the user
//                    
//                    destination = .alert(.init(title: { .init("There was more than one entry that matched that usage's. This is not currently supported.")}))
//                    
//                } else {
//                    db.connect(usage: first.id, toEntry: entryID)
//                }
//                
//            } else {
//                
//                let value = textField.text
//                let valueLanguage = textField.language
//                
//                let newUsage = db.createNewUsage(language: valueLanguage) {
//                    $0.value = value
//                }
//                
//                db.connect(usage: newUsage.id, toEntry: entryID)
//                                    
//            }
//                                            
//            return .none
//
//        }
//    }
//    
//    @Reducer(state: .equatable)
//    public enum Destination {
//        case alert(AlertState<Never>)
//        case confirmationDialog(ConfirmationDialogState<EntryUsagesEditor.ConfirmationDialog>)
//    }
//    
//    public enum ConfirmationDialog: Equatable {
//        case cancel
//        case addUsageAsExistingEntry(Entry)
//        case addUsageAsNewEntry
//    }
//
//    public enum Action: BindableAction {
//        case binding(BindingAction<State>)
//        case destination(PresentationAction<Destination.Action>)
//        case textField(ToolbarTextField.Action)
//        
//        case addButtonTapped
//        case addLongPressMenuButtonTapped(Language)
//        case destructiveSwipeButtonTapped(Usage)
//        case moved(fromOffsets: IndexSet, toOffset: Int)
//        
//        case delegate(Delegate)
//        public enum Delegate {
//            case selected(Usage)
//        }
//    }
//
//    public var body: some ReducerOf<Self> {
//        
//        BindingReducer()
//        
//        Scope(state: \.textField, action: \.textField) {
//            ToolbarTextField()
//        }
//        
//        Reduce<State, Action> { state, action in
//            switch action {
//            case .delegate: return .none
//            case .binding: return .none
//            case .destination: return .none
//
//            case .addButtonTapped:
//
//                state.textField.languageOverride = .none
//                state.textField.collapsed = false
//                
//                return .none
//
//            case .addLongPressMenuButtonTapped(let selected):
//
//                state.textField.languageOverride = selected.id
//                state.textField.collapsed = false
//
//                return .none
//
//            case .textField(.delegate(let delegatedAction)):
//                switch delegatedAction {
//                case .fieldCommitted, .saveEntryButtonTapped:
//                    return state.submitCurrentFieldValueAsUsage()
//                }
//            case .textField: return .none
//            case .destructiveSwipeButtonTapped(let usage):
//
//                state.db.disconnect(usage: usage.id, fromEntry: state.entryID)
//                
//                return .none
//
//            case .moved(let fromOffsets, let toOffset):
//
//                state.db.moveUsages(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
//
//                return .none
//            }
//        }
//        .ifLet(\.$destination, action: \.destination)
//    }
//}
//
//extension ConfirmationDialogState {
//    static func addOrUseExisting(entry: Entry) -> Self where Action == EntryUsagesEditor.ConfirmationDialog {
//        .init(
//            title: {
//                .init("A word spelled \"\(entry.spelling)\" already exists")
//            },
//            actions: {
//                ButtonState<Action>.init(
//                    action: .cancel, label: { .init("Cancel") }
//                )
//                ButtonState<Action>.init(
//                    action: .addUsageAsNewEntry, label: { .init("Create new entry") }
//                )
//                ButtonState<Action>.init(
//                    action: .addUsageAsExistingEntry(entry), label: { .init("Use existing") }
//                )
//            },
//            message: {
//                .init("Would you like to use it or create a new entry with the same spelling?")
//            }
//        )
//    }
//}
//
//extension Usage: CategorizedItem {}
//extension Language: CategorizedItemsSectionCategory {
//    public var title: String { displayName }
//}
//
//struct EntryUsagesEditorView: View {
//    
//    @Bindable var store: StoreOf<EntryUsagesEditor>
//    
//    var body: some View {
//        CategorizedItemsSection(
//            title: "Usages",
//            items: store.usages,
//            availableCategories: store.settings.languageSelectionList.map({ $0 }),
//            onSelected: { store.send(.delegate(.selected($0))) },
//            onDeleted: { store.send(.destructiveSwipeButtonTapped($0)) },
//            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
//            onMenuItemTapped: { store.send(.addLongPressMenuButtonTapped($0)) },
//            onMenuShortPressed: { store.send(.addButtonTapped) }
//        )
//    }
//}
