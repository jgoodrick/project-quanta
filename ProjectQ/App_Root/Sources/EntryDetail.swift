
import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        let entry: Entry
        var spelling: FloatingTextField.State = .init()
        var translation: FloatingTextField.State = .init()
        var translationLanguage: LanguageSelection = .systemCurrent
        @Shared(.languageSelectionList) var languageSelectionList
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
        case mergeWithExisting(Entry)
        case updateSpellingWithoutMerging
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
        case translation(FloatingTextField.Action)

        case task
        case editSpellingButtonTapped
        case editLanguageMenuButtonSelected(LanguageSelection)
        case addTranslationButtonTapped
        case addTranslationLongPressMenuButtonTapped(LanguageSelection)
        case translationSelected(Translation)
        case translationDestructiveSwipeButtonTapped(Translation)
        case movedTranslation(fromOffsets: IndexSet, toOffset: Int)

        case foundMatchForUpdatedSpelling(Entry)
        case shouldUpdateSpelling

    }

    @Dependency(\.actorContext) var actorContext
    @Dependency(\.modelContainer) var modelContainer

    @MainActor
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
                                
                if let newLanguage = try? modelContainer.fetchLanguageBy(definition: selected, createIfMissing: true) {
                    
                    state.entry.language = newLanguage
                    
                } else {
                    
                    state.destination = .alert(.init(title: { .init("Failed to change the language") }))
                    
                }

                return .none

            case .addTranslationButtonTapped:

                @Dependency(\.languages) var languages
                
                if let systemValue = state.languageSelectionList.first(where: { $0.id == languages.device().identifier }) {

                    state.translationLanguage = systemValue
                    state.translation.collapsed = false
                    return .none

                } else {

                    struct MissingSystemLocaleError: Error {}

                    return .run { send in
                        throw MissingSystemLocaleError()
                    }

                }

            case .addTranslationLongPressMenuButtonTapped(let selected):

                state.translationLanguage = selected
                state.translation.collapsed = false

                return .none

            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:

                    let spelling = state.spelling.text

                    guard !spelling.isEmpty else {
                        state.spelling = .init()
                        return .none
                    }

                    return .run { send in

                        let context = try actorContext()

                        let matches = try await context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.spelling == spelling }))

                        if let match = matches.first {

                            await send(.foundMatchForUpdatedSpelling(match))

                        } else {

                            await send(.shouldUpdateSpelling)

                        }
                    }

                }
            case .spelling: return .none
            case .foundMatchForUpdatedSpelling(let match):

                state.destination = .confirmationDialog(.addOrMergeWithExisting(entry: match))

                return .none

            case .shouldUpdateSpelling, .destination(.presented(.confirmationDialog(.updateSpellingWithoutMerging))):

                state.entry.spelling = state.spelling.text

                return .none

            case .destination(.presented(.confirmationDialog(.mergeWithExisting(let entry)))):

                // TODO: handle the actual merging here

                return .none

            case .destination(.presented(.confirmationDialog(.cancel))):

                state.spelling = .init()

                return .none

            case .destination: return .none
            case .translation(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:

//                    if let match = state.$entries.matching(spelling: state.translation.text) {
//
//                        state.$entries.establishTranslationConnectionBetween(state.$entry, and: match)
//
//                    } else if !state.translation.text.isEmpty {
//
//                        @Dependency(\.uuid) var uuid
//                        @Dependency(\.date.now) var now
//
//                        let new = state.$entries.add(new: .init(
//                            id: uuid(),
//                            locale: state.translationLocale,
//                            added: now,
//                            lastModified: now,
//                            spelling: state.translation.text
//                        ))
//
//                        state.$entries.establishTranslationConnectionBetween(state.$entry, and: new)
//
//                    }
//
//                    state.translation = .init()

                    return .none

                }
            case .translation: return .none
            case .translationSelected(let translation):

                state.destination = .related(.init(entry: translation.to))

                return .none

            case .translationDestructiveSwipeButtonTapped(let translation):

                modelContainer.mainContext.delete(translation)
                
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
    static func addOrMergeWithExisting(entry: Entry) -> Self where Action == EntryDetail.ConfirmationDialog {
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
    
    @Environment(\.locale) private var locale

    var body: some View {
        Section {
            Text(store.entry.language.displayName)
        } header: {
            HStack(alignment: .firstTextBaseline) {
                
                Text("Language")
                    .font(.footnote)
                    .textCase(.uppercase)
                
                Spacer()
                
                Menu {
                    ForEach(store.languageSelectionList) { menuItem in
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
            ForEach(store.entry.translations) { translation in
                HStack {
                    Button(action: { store.send(.translationSelected(translation)) }) {
                        Text("\(translation.to.spelling)")
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
                    ForEach(store.languageSelectionList) { menuItem in
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
        Form {
//            
//            EntryDetailLanguageSection(store: store)
//            
//            EntryDetailTranslationSection(store: store)
//            
        }
//        .toolbar {
//            ToolbarItem {
//                Button(action: { store.send(.editSpellingButtonTapped) }) {
//                    Image(systemName: "pencil")
//                }
//            }
//        }
//        .safeAreaInset(edge: .bottom) {
//            VStack {
//                
//                Spacer()
//                        
//                if !store.spelling.collapsed {
//                    FloatingTextFieldView(
//                        store: store.scope(state: \.spelling, action: \.spelling)
//                    )
//                } else if !store.translation.collapsed {
//                    FloatingTextFieldView(
//                        store: store.scope(state: \.translation, action: \.translation)
//                    )
//                    .environment(\.locale, store.translationLocale)
//                }
//                
//            }
//            .padding()
//        }
//        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
////        .scrollContentBackground(.hidden)
//        .navigationDestination(item: $store.scope(state: \.destination?.related, action: \.destination.related)) { store in
//            EntryDetailView(store: store)
//        }
//        .navigationTitle(store.entry.spelling)
//        .environment(\.locale, store.entry.locale)
//        .task { await store.send(.task).finish() }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}

//#Preview { Preview }
//private var Preview: some View {
//    let exampleEntries: Entries = .mock(all: [
//        Entry.init(
//            id: .init(0),
//            locale: .init(
//                languageCode: .ukrainian,
//                script: .cyrillic,
//                languageRegion: .ukraine
//            ),
//            added: .now,
//            lastModified: .now,
//            spelling: "Про",
//            translations: [
//                .init(1),
//                .init(2),
//            ],
//            examples: [
//                "An example sentence using the ukraininan word for \"about\"",
//            ],
//            notes: []
//        ),
//        Entry.init(
//            id: .init(1),
//            locale: .init(
//                languageCode: .english,
//                script: .latin,
//                languageRegion: .unitedStates
//            ),
//            added: .now,
//            lastModified: .now,
//            spelling: "about",
//            translations: [],
//            examples: [],
//            notes: []
//        ),
//        Entry.init(
//            id: .init(2),
//            locale: .init(
//                languageCode: .english,
//                script: .latin,
//                languageRegion: .unitedStates
//            ),
//            added: .now,
//            lastModified: .now,
//            spelling: "around",
//            translations: [],
//            examples: [],
//            notes: []
//        ),
//    ])
//    @Shared(.entries) var entries = exampleEntries
//    let detailed = $entries[id: .init(0)]!
//    return NavigationStack {
//        EntryDetailView(store: .init(initialState: .init(entry: detailed)) {
//            EntryDetail()._printChanges()
//        })
//    }
//}
