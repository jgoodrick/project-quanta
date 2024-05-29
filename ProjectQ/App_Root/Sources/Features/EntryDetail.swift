
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        let entry: Entry
        var spelling: FloatingTextField.State
        var translation: FloatingTextField.State
        var translationLanguage: Language?
        @Shared(.settings) var settings
        @Presents var destination: Destination.State?
        var aggregated: Entry.Aggregate {
            fatalError()
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
        case mergeWithExisting(Entry)
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
        case translationSelected(Entry)
        case translationDestructiveSwipeButtonTapped(Entry)
        case movedTranslation(fromOffsets: IndexSet, toOffset: Int)

    }

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

                
//                if let selectedLanguage = modelContainer.mainContext.language(for: selected, createIfMissing: true) {
//                    
//                    state.entry.language = selectedLanguage
//                    
//                } else {
//                    
//                    state.destination = .alert(.init(title: { .init("Failed to insert the new language into the database: \(selected.displayName)") }))
//                    
//                }

                return .none

            case .addTranslationButtonTapped:

                @Dependency(\.locale) var systemLocale
                
//                if let systemValue = modelContainer.mainContext.language(for: .bcp47(systemLocale.identifier(.bcp47)), createIfMissing: true) {
//
//                    state.translationLanguage = systemValue.definition
//                    state.translation.collapsed = false
                    return .none
//
//                } else {
//
//                    struct MissingSystemLocaleError: Error {}
//
//                    return .run { send in
//                        throw MissingSystemLocaleError()
//                    }
//
//                }

            case .addTranslationLongPressMenuButtonTapped(let selected):

                state.translationLanguage = selected
                state.translation.collapsed = false

                return .none

            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    let spelling = state.spelling.text
                    
                    guard !spelling.isEmpty else {
//                        state.spelling = .init()
                        return .none
                    }
                    
                    do {
                        
//                        let matches = try modelContainer.mainContext.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.spelling == spelling }))
//                        
//                        if let match = matches.first {
//                            
//                            state.destination = .confirmationDialog(.addOrMergeWithExisting(entry: match))
//                            
//                        } else {
//                            
//                            state.entry.spelling = state.spelling.text
//                            
//                        }
                                         
                    } catch {
                        
                        state.destination = .alert(.init(title: { .init("Failed to fetch spelling matches due to: \(error.localizedDescription)") }))

                    }

                }
            
                return .none

            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.updateSpellingWithoutMerging))):

//                state.entry.spelling = state.spelling.text

                return .none

            case .destination(.presented(.confirmationDialog(.mergeWithExisting(let existing)))):

//                modelContainer.mainContext.delete(state.entry)
//
//                @Dependency(\.date) var date
//                                
//                existing.modified = date.now
//                
//                for translation in state.entry.translations {
//                    if !existing.translations.contains(translation) {
//                        existing.translations.append(translation)
//                    }
//                }
//                        
//                for keyword in state.entry.keywords {
//                    if !existing.keywords.contains(keyword) {
//                        existing.keywords.append(keyword)
//                    }
//                }
//                
//                for note in state.entry.notes {
//                    note.entry = existing
//                }

                return .none

            case .destination(.presented(.confirmationDialog(.cancel))):

//                state.spelling = .init()

                return .none

            case .destination: return .none
            case .translation(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    break
                    
//                    let translationSpelling = state.translation.text
//                    
//                    guard !translationSpelling.isEmpty else {
//                        state.translation = .init()
//                        return .none
//                    }
//                    
//                    let matches: [Entry]
//                    
//                    do {
//
//                        matches = try modelContainer.mainContext.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.spelling == translationSpelling }))
//                        
//                    } catch {
//                        
//                        state.destination = .alert(.init(title: { .init("Failed to handle translation delegated action due to: \(error.localizedDescription)") }))
//                        
//                        return .none
//                        
//                    }
//
//                    @Dependency(\.date) var date
//                    
//                    let now = date.now
//                    
//                    if let match = matches.first {
//                        
//                        if matches.count > 1 {
//                            
//                            // what if there are more than one words in the repo that match the spelling of the translation the user just typed in? (Because the user previously decided to create a separate word with the same spelling instead of merging or editing the existing one). We will need to handle this with a confirmation dialog, as we have done previously.
//                            // TODO: handle more than one match
//                            
//                            state.destination = .alert(.init(title: { .init("There was more than one entry that matched that translation's spelling. This is not currently supported.")}))
//                            
//                        } else {
//                                                        
//                            state.entry.translations.append(match)
//                                                        
//                        }
//                        
//                    } else {
//                        
//                        // create both an entry for the newly typed word, and hook that new entry up as a translation of the focused entry
//                        
//                        guard let selectedLanguage = modelContainer.mainContext.language(for: state.translationLanguage, createIfMissing: true) else {
//                            
//                            state.destination = .alert(.init(title: { .init("Failed to insert the translation language into the database: \(state.translationLanguage.displayName)") }))
//                            
//                            return .none
//                            
//                        }
//                        
//                        let newEntryForTranslation = Entry(
//                            added: now,
//                            modified: now,
//                            spelling: translationSpelling
//                        )
//                        
//                        modelContainer.mainContext.insert(newEntryForTranslation)
//                        
//                        newEntryForTranslation.language = selectedLanguage
//                        
//                        state.entry.translations.append(newEntryForTranslation)
//                        
//                    }
//                    
//                    state.translation = .init()
//                                            
                }
                    
                return .none

            case .translation: return .none
            case .translationSelected(let translation):

//                state.destination = .related(.init(entry: translation))

                return .none

            case .translationDestructiveSwipeButtonTapped(let translation):

//                state.entry.translations.removeAll(where: { $0.persistentModelID == translation.persistentModelID })
                
                return .none

            case .movedTranslation(let fromOffsets, let toOffset):

//                state.entry.translations.move(fromOffsets: fromOffsets, toOffset: toOffset)

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
            Text(store.aggregated.language?.displayName ?? "Not Set")
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
            ForEach(store.aggregated.translations) { translation in
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
        Form {
            
            EntryDetailLanguageSection(store: store)
            
            EntryDetailTranslationSection(store: store)
            
        }
//        .toolbar {
//            ToolbarItem {
//                Button(action: { store.send(.editSpellingButtonTapped) }) {
//                    Image(systemName: "pencil")
//                }
//            }
//        }
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
//                    .environment(\.language, store.translationLanguage)
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
//        .environment(\.language, store.entry.language?.definition ?? .defaultValue)
        .task { await store.send(.task).finish() }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
