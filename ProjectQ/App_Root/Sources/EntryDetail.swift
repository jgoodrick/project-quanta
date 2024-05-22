
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        public init(entry: Shared<Entry>, destination: Destination.State? = .none) {
            self._entry = entry
            self.destination = destination
        }
        @Shared public var entry: Entry
        @Shared(.entries) public var entries: Entries
        @Shared(.inputLocales) var inputLocales
        @Presents var destination: Destination.State?
        var spelling: FloatingTextField.State = .init()
        var translation: FloatingTextField.State = .init()
        var translationLocale: Locale = .current
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case confirmationDialog(ConfirmationDialogState<EntryDetail.ConfirmationDialog>)
        case related(EntryDetail)
    }
    
    public enum ConfirmationDialog: Equatable {
        case cancel
        case editExisting(Shared<Entry>)
        case addNew
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
        case translation(FloatingTextField.Action)

        case task
        case editSpellingButtonTapped
        case editLanguageMenuButtonSelected(Locale)
        case addTranslationButtonTapped
        case addTranslationLongPressMenuButtonTapped(Locale)
        case translationSelected(Shared<Entry>)
        case translationDestructiveSwipeButtonTapped(Shared<Entry>)
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
            case .destination: return .none
            case .task: return .none
            case .editSpellingButtonTapped: 
                
                state.spelling.collapsed = false
                
                return .none
                
            case .editLanguageMenuButtonSelected(let selected):
                
                state.entry.locale = selected
                
                return .none
                
            case .addTranslationButtonTapped:
                
                if let systemValue = state.inputLocales.first(where: { $0.id == Locale.current.id }) {
                    
                    state.translationLocale = systemValue
                    state.translation.collapsed = false
                    return .none

                } else {
                    
                    struct MissingSystemLocaleError: Error {}

                    return .run { send in
                        throw MissingSystemLocaleError()
                    }
                    
                }
                
            case .addTranslationLongPressMenuButtonTapped(let selected):
                
                state.translationLocale = selected
                state.translation.collapsed = false
                
                return .none
                
            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    if let match = state.$entries.matching(spelling: state.spelling.text) {
                        
                        // handle the merging or duplicating of entries?
                        state.destination = .confirmationDialog(.addOrEditExisting(entry: match))
                        
                    } else if !state.spelling.text.isEmpty {
                        
                        // mutate it in place
                        
                        state.entry.spelling = state.spelling.text
                        
                    }

                    state.spelling = .init()

                    return .none

                }
            case .spelling: return .none
            case .translation(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    if let match = state.$entries.matching(spelling: state.translation.text) {
                        
                        state.$entries.establishTranslationConnectionBetween(state.$entry, and: match)
                        
                    } else if !state.translation.text.isEmpty {
                        
                        @Dependency(\.uuid) var uuid
                        @Dependency(\.date.now) var now
                        
                        let new = state.$entries.add(new: .init(
                            id: uuid(),
                            locale: state.translationLocale,
                            added: now,
                            lastModified: now,
                            spelling: state.translation.text
                        ))
                        
                        state.$entries.establishTranslationConnectionBetween(state.$entry, and: new)

                    }

                    state.translation = .init()

                    return .none

                }
            case .translation: return .none
            case .translationSelected(let translation):
                
                state.destination = .related(.init(entry: translation))
                
                return .none
                
            case .translationDestructiveSwipeButtonTapped(let entry):
                
                state.$entries.removeTranslationConnectionBetween(state.$entry, and: entry)
                
                return .none
                
            case .movedTranslation(let fromOffsets, let toOffset):
                                
                state.entry.translations.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none

            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Shared<Entry>) -> Self where Action == EntryDetail.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" has already been added")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .addNew, label: { .init("Add New") }
                )
                ButtonState<Action>.init(
                    action: .editExisting(entry), label: { .init("Edit Existing") }
                )
            },
            message: {
                .init("Would you like to edit it, or add a new word with the same spelling?")
            }
        )
    }
}

struct EntryDetailLanguageSection: View {
    
    let store: StoreOf<EntryDetail>
    
    @Environment(\.locale) private var locale

    var body: some View {
        Section {
            Text(store.entry.locale.displayName(in: locale))
        } header: {
            HStack(alignment: .firstTextBaseline) {
                
                Text("Language")
                    .font(.footnote)
                    .textCase(.uppercase)
                
                Spacer()
                
                Menu {
                    ForEach(store.inputLocales) { inputLocale in
                        Button(action: {
                            store.send(.editLanguageMenuButtonSelected(inputLocale))
                        }) {
                            Label(inputLocale.displayName().capitalized, systemImage: "flag")
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
            ForEach(store.entry.identifiedTranslations) { $translation in
                HStack {
                    Button(action: { store.send(.translationSelected($translation)) }) {
                        Text("\(translation.spelling)")
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.translationDestructiveSwipeButtonTapped($translation))
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
                    ForEach(store.inputLocales) { inputLocale in
                        Button(action: {
                            store.send(.addTranslationLongPressMenuButtonTapped(inputLocale))
                        }) {
                            Label(inputLocale.displayName().capitalized, systemImage: "flag")
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
                    .environment(\.locale, store.translationLocale)
                }
                
            }
            .padding()
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.related, action: \.destination.related)) { store in
            EntryDetailView(store: store)
        }
        .navigationTitle(store.entry.spelling)
        .environment(\.locale, store.entry.locale)
        .task { await store.send(.task).finish() }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}

#Preview { Preview }
private var Preview: some View {
    let exampleEntries: Entries = .mock(all: [
        Entry.init(
            id: .init(0),
            locale: .init(
                languageCode: .ukrainian,
                script: .cyrillic,
                languageRegion: .ukraine
            ),
            added: .now,
            lastModified: .now,
            spelling: "Про",
            translations: [
                .init(1),
                .init(2),
            ],
            examples: [
                "An example sentence using the ukraininan word for \"about\"",
            ],
            notes: []
        ),
        Entry.init(
            id: .init(1),
            locale: .init(
                languageCode: .english,
                script: .latin,
                languageRegion: .unitedStates
            ),
            added: .now,
            lastModified: .now,
            spelling: "about",
            translations: [],
            examples: [],
            notes: []
        ),
        Entry.init(
            id: .init(2),
            locale: .init(
                languageCode: .english,
                script: .latin,
                languageRegion: .unitedStates
            ),
            added: .now,
            lastModified: .now,
            spelling: "around",
            translations: [],
            examples: [],
            notes: []
        ),
    ])
    @Shared(.entries) var entries = exampleEntries
    let detailed = $entries[id: .init(0)]!
    return NavigationStack {
        EntryDetailView(store: .init(initialState: .init(entry: detailed)) {
            EntryDetail()._printChanges()
        })
    }
}
