
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        
        init(entry entryID: Entry.ID) {
            self.entryID = entryID
            @Shared(.db) var database
            let expanded = $database[entry: entryID]
            @Dependency(\.systemLanguages) var systemLanguages
            let system = systemLanguages.current()
            self.spelling = .init(languageOverride: expanded?.language?.id ?? system.id)
            self.translation.languageOverride = system.id
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        var entryID: Entry.ID
        var spelling: FloatingTextField.State
        var translation: FloatingTextField.State = .init()
        
        @Presents var destination: Destination.State?
        
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryDetail.ConfirmationDialog>)
        case related(EntryDetail)
    }
    
    public enum ConfirmationDialog: Equatable {
        case cancel
        case mergeWithExisting(Entry.Expansion)
        case updateSpellingWithoutMerging
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
        case translation(FloatingTextField.Action)

        case task
        case editSpellingButtonTapped
        case editLanguageMenuButtonSelected(Language)
        case addTranslationButtonTapped
        case addTranslationLongPressMenuButtonTapped(Language)
        case translationSelected(Entry.Expansion)
        case translationDestructiveSwipeButtonTapped(Entry.Expansion)
        case movedTranslation(fromOffsets: IndexSet, toOffset: Int)

    }

    public var body: some ReducerOf<Self> {
        
        Scope(state: \.spelling, action: \.spelling) {
            FloatingTextField()
        }
        
        Scope(state: \.translation, action: \.translation) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .task: return .none
            case .editSpellingButtonTapped:

                state.spelling.collapsed = false

                return .none

            case .editLanguageMenuButtonSelected(let selected):

                state.db.updateLanguage(to: selected.id, for: state.entryID)

                return .none

            case .addTranslationButtonTapped:

                @Dependency(\.systemLanguages) var systemLanguages

                state.translation.collapsed = false
                state.translation.languageOverride = systemLanguages.current().id
                return .none

            case .addTranslationLongPressMenuButtonTapped(let selected):

                state.translation.languageOverride = selected.id
                state.translation.collapsed = false

                return .none

            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: return state.submitCurrentFieldValueAsUpdatedSpelling()
                }
            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.updateSpellingWithoutMerging))):

                state.db.updateEntry(\.spelling, on: state.entryID, to: state.spelling.text)

                return .none

            case .destination(.presented(.confirmationDialog(.mergeWithExisting(let existing)))):

                let preMergeID = state.entryID
                
                state.entryID = existing.id
                
                state.db.merge(entry: preMergeID, into: existing.id)

                return .none

            case .destination(.presented(.confirmationDialog(.cancel))):

                state.spelling.reset()

                return .none

            case .destination: return .none
            case .translation(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: return state.submitCurrentFieldValueAsTranslation()
                }
            case .translation: return .none
            case .translationSelected(let translation):

                state.destination = .related(.init(entry: translation.id))

                return .none

            case .translationDestructiveSwipeButtonTapped(let translation):

                state.db.remove(translation: translation.id, from: state.entryID)
                
                return .none

            case .movedTranslation(let fromOffsets, let toOffset):

                state.db.moveTranslations(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrMergeWithExisting(entry: Entry.Expansion) -> Self where Action == EntryDetail.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .updateSpellingWithoutMerging, label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .mergeWithExisting(entry), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
}

struct EntryDetailLanguageSection: View {
    
    let store: StoreOf<EntryDetail>
        
    var body: some View {
        Section {
            Text(store.languageName)
        } header: {
            HStack(alignment: .firstTextBaseline) {
                
                Text("Language")
                    .font(.footnote)
                    .textCase(.uppercase)
                
                Spacer()
                
                Menu {
                    ForEach(store.settings.languageSelectionList) { menuItem in
                        Button(action: {
                            store.send(.editLanguageMenuButtonSelected(menuItem))
                        }) {
                            Label(menuItem.displayName.capitalized, systemImage: "flag")
                        }
                    }
                } label: {
                    Text("Edit")
                        .font(.callout)
                        .textCase(.lowercase)
                }
                
            }
        }
    }
}

struct EntryDetailTranslationSection: View {
    
    let store: StoreOf<EntryDetail>
    
    var body: some View {
        Section {
            ForEach(store.translations) { translation in
                HStack {
                    Button(action: { store.send(.translationSelected(translation)) }) {
                        Text("\(translation.spelling)")
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.translationDestructiveSwipeButtonTapped(translation))
                        },
                        label: {
                            Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                        }
                    )
                }
            }
            .onMove { from, to in
                store.send(.movedTranslation(fromOffsets: from, toOffset: to))
            }

        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Translations")
                
                Spacer()
                
                Menu(content: {
                    // long press
                    ForEach(store.settings.languageSelectionList) { menuItem in
                        Button(action: {
                            store.send(.addTranslationLongPressMenuButtonTapped(menuItem))
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
                    store.send(.addTranslationButtonTapped)
                })
            }
        }
    }
}

public struct EntryDetailView: View {
    
    @Bindable public var store: StoreOf<EntryDetail>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
    }
    
    @Environment(\.entryDetail) private var style
    
    public var body: some View {
        Group {
            if let entry = store.entry {
                Form {
                    
                    EntryDetailLanguageSection(store: store)
        
                    EntryDetailTranslationSection(store: store)
                    
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: { store.send(.editSpellingButtonTapped) }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        
                        Spacer()
                                
                        if !store.spelling.collapsed {
                            FloatingTextFieldView(
                                store: store.scope(state: \.spelling, action: \.spelling)
                            )
                        } else if !store.translation.collapsed {
                            FloatingTextFieldView(
                                store: store.scope(state: \.translation, action: \.translation)
                            )
                        }
                        
                    }
                    .padding()
                }
                .navigationTitle(entry.spelling)
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.related, action: \.destination.related)) { store in
            EntryDetailView(store: store)
        }
        .task { await store.send(.task).finish() }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
