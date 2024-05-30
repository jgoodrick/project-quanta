
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        
        init(entry: Entry.ID) {
            @Shared(.db) var shared
            @Dependency(\.systemLanguages) var systemLanguages
            let system = systemLanguages.current()
            self.entryID = entry
            self.spelling = .init(language: $shared[entry: entry]?.language ?? system)
            self.translation = .init(language: system)
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        var entryID: Entry.ID
        var entry: Entry.Expansion? { $db[entry: entryID] }
        var spelling: FloatingTextField.State
        var translation: FloatingTextField.State
        
        @Presents var destination: Destination.State?
        
        var translations: [Entry.Expansion] {
            $db.translations(for: entryID)
        }
        
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

                state.translation.language = systemLanguages.current()
                state.translation.collapsed = false
                return .none

            case .addTranslationLongPressMenuButtonTapped(let selected):

                state.translation.language = selected
                state.translation.collapsed = false

                return .none

            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:

                    let spelling = state.spelling.text

                    guard !spelling.isEmpty else {
                        state.spelling.reset()
                        return .none
                    }

                    if let match = state.$db.firstEntry(where: \.spelling, is: spelling) {

                        state.destination = .confirmationDialog(.addOrMergeWithExisting(entry: match))

                    } else {

                        state.db.updateEntry(\.spelling, on: state.entryID, to: state.spelling.text)

                    }

                }

                return .none

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
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    let translationSpelling = state.translation.text
                    
                    guard !translationSpelling.isEmpty else {
                        state.translation.reset()
                        return .none
                    }
                    
                    let matches = state.$db.entries(where: \.spelling, is: translationSpelling)
                    
                    if let first = matches.first {
                        
                        if matches.count > 1 {
                            
                            // what if there are more than one words in the repo that match the spelling of the translation the user just typed in? (Because the user previously decided to create a separate word with the same spelling instead of merging or editing the existing one). We will need to handle this with a confirmation dialog, as we have done previously.
                            // TODO: handle more than one match
                            
                            state.destination = .alert(.init(title: { .init("There was more than one entry that matched that translation's spelling. This is not currently supported.")}))
                            
                        } else {
                            
                            state.db.add(translation: first.id, to: state.entryID)

                        }

                    } else {
                        
                        do {
                            
                            let translationSpelling = state.translation.text
                            let translationLanguage = state.translation.language
                            
                            let newEntry = try state.$db.addNewEntry(language: translationLanguage) {
                                $0.spelling = translationSpelling
                            }
                            
                            state.db.add(translation: newEntry.id, to: state.entryID)
                            
                        } catch {
                            
                            state.destination = .alert(.init(title: { .init("Failed to add a new translation: \(error.localizedDescription)") }))
                            
                        }
                        
                    }
                    
                    state.translation.reset()
                                            
                }
                    
                return .none

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
    
    var languageName: String {
        store.entry?.language?.displayName ?? "Not Set"
    }
    
    var body: some View {
        Section {
            Text(languageName)
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
    
    var navTitle: String {
        store.entry?.spelling ?? "[Unknown Entry]"
    }
    
    public var body: some View {
        Group {
            if store.entry != nil {
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
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.related, action: \.destination.related)) { store in
            EntryDetailView(store: store)
        }
        .navigationTitle(navTitle)
        .task { await store.send(.task).finish() }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
