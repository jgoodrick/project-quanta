
import AppModel
import ComposableArchitecture
import Foundation
import LayoutCore
import StructuralModel
import SwiftUI

@Reducer
public struct EntryDetail {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        public init(entry entryID: Entry.ID, translationsEditorFocused: Bool) {
            let shared = Shared(entryID)
            self._entryID = shared
            self.shouldLaunchTranslationsEditorImmediately = translationsEditorFocused
        }
        
        @Shared(.model) var model
        
        @Shared var entryID: Entry.ID
        var textField: TextFieldState = .init()
        struct TextFieldState: Equatable {
            var text: String = ""
            var isFocused: Bool {
                get { target != nil }
                set {
                    if newValue {
                        
                    } else {
                        target = nil
                    }
                }
            }
            var languageOverride: Language?
            var placeholder: String = ""
            var autocapitalization: Autocapitalization = .none
            var target: ToolbarTarget?
        }
        var shouldLaunchTranslationsEditorImmediately: Bool = false
        
        @Presents var destination: Destination.State?

    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)

        // text field
        case textInputCouldNotMatchLanguage(id: String)
        case toolbarTextFieldSaveButtonTapped
        case toolbarTextFieldSubmitted
        case tappedOutsideActiveToolbarTextField
        case keyboardToolbarDoneButtonTapped
        
        // language section
        case addLanguageMenuButtonTapped(Language)
        case languageCellDestructiveSwipeButtonTapped(Language)
        case movedLanguage(fromOffsets: IndexSet, toOffset: Int)

        // spelling section
        case editSpellingButtonTapped
        
        // translations section
        case addNewTranslationButtonTapped
        case addNewCustomLanguageTranslationButtonTapped(Language)
        case translationCellTapped(Entry)
        case translationCellDestructiveSwipeButtonTapped(Entry)
        case movedTranslation(fromOffsets: IndexSet, toOffset: Int)

        // usage section
        case addNewUsageButtonTapped
        case addNewCustomLanguageUsageButtonTapped(Language)
        case usageCellTapped(Usage)
        case usageCellDestructiveSwipeButtonTapped(Usage)
        case movedUsage(fromOffsets: IndexSet, toOffset: Int)

        // notes section
        case addNewNoteButtonTapped
        case noteCellTapped(Note)
        case noteCellDestructiveSwipeButtonTapped(Note)
        case movedNote(fromOffsets: IndexSet, toOffset: Int)

        // lifecycle
        case task
        case navigationAnimationTimerFinished
        
        // delegated
        case delegated(Delegated)
        public enum Delegated {
            case translationCellTapped(Entry)
        }
    }
    
    @Dependency(\.logger["\(Self.self)"]) var log

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegated: return .none
            case .binding: return .none
            case .toolbarTextFieldSubmitted, .toolbarTextFieldSaveButtonTapped:

                return state.submitText()

            case .textInputCouldNotMatchLanguage(let id):
                
                log.warning("Text input could not find or match language id: \(id)")
                
                state.destination = .keyboardUnavailable(.directUserToSettingsToSetUpKeyboard())
                
                return .none
                
            case .tappedOutsideActiveToolbarTextField:
                
                state.resetToolbarTextField()
                
                return .none

            case .keyboardToolbarDoneButtonTapped:
                
                state.resetToolbarTextField()
                
                return .none

            case .task:
                
                state.resetToolbarTextField()

                guard state.shouldLaunchTranslationsEditorImmediately else {
                    return .none
                }
                
                return .run { send in
                    @Dependency(\.continuousClock) var clock
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.navigationAnimationTimerFinished)
                }
                
            case .navigationAnimationTimerFinished:
                
                state.resetToolbarTextField(to: .newTranslation)

                return .none
                
            // Add/Edit Actions
            
            case .editSpellingButtonTapped:

                state.resetToolbarTextField(to: .spelling)

                return .none

            case .addLanguageMenuButtonTapped(let language):

                state.model.addExisting(language: language.id, toEntry: state.entryID)

                return .none

            case .addNewTranslationButtonTapped:
                
                state.resetToolbarTextField(to: .newTranslation)

                return .none
                
            case .addNewCustomLanguageTranslationButtonTapped(let languageOverride):
                
                state.resetToolbarTextField(to: .newTranslation, languageOverride: languageOverride)

                return .none

            case .addNewUsageButtonTapped:
                
                state.resetToolbarTextField(to: .usage(nil))
                
                return .none
                
            case .addNewCustomLanguageUsageButtonTapped(let languageOverride):

                state.resetToolbarTextField(to: .usage(nil), languageOverride: languageOverride)
                
                return .none

            case .addNewNoteButtonTapped:
                
                state.resetToolbarTextField(to: .note(nil))

                return .none
                
            // Selection Actions

            case .translationCellTapped(let translation):

                return .send(.delegated(.translationCellTapped(translation)))
                
            case .usageCellTapped(let usage):
                
                state.resetToolbarTextField(to: .usage(usage.id))
                
                return .none
                
            case .noteCellTapped(let note):
                
                state.resetToolbarTextField(to: .note(note.id))
                
                return .none
                
            // Destructive Actions
                
            case .languageCellDestructiveSwipeButtonTapped(let language):

                state.model.remove(language: language.id, fromEntry: state.entryID)

                return .none

            case .translationCellDestructiveSwipeButtonTapped(let translation):
                
                if state.model.entity(.entry(translation.id), wouldBeOrphanIfRemovedFrom: .entry(state.entryID)) {
                    state.destination = .orphanedIfRemoved(.confirmDeletion(of: .translation(translation)))
                } else {
                    state.model.remove(translation: translation.id, fromEntry: state.entryID)
                }
                
                return .none
                
            case .usageCellDestructiveSwipeButtonTapped(let usage):
                
                if state.model.entity(.usage(usage.id), wouldBeOrphanIfRemovedFrom: .entry(state.entryID)) {
                    state.destination = .orphanedIfRemoved(.confirmDeletion(of: .usage(usage)))
                } else {
                    state.model.remove(usage: usage.id, fromEntry: state.entryID)
                }

                return .none
                
            case .noteCellDestructiveSwipeButtonTapped(let note):
                
                if state.model.entity(.note(note.id), wouldBeOrphanIfRemovedFrom: .entry(state.entryID)) {
                    state.destination = .orphanedIfRemoved(.confirmDeletion(of: .note(note)))
                } else {
                    state.model.remove(note: note.id, fromEntry: state.entryID)
                }

                return .none
                
            case .destination(.presented(.spellingUpdateConflict(let resolution))):

                state.resolveSpellingUpdateConflict(resolution: resolution)

                return .none

            case .destination(.presented(.newTranslationSpellingConflict(let resolution))):

                state.resolveTranslationSpellingConflict(resolution: resolution)
                
                return .none

            case .destination(.presented(.orphanedIfRemoved(let resolution))):
                
                state.resolveOrphanedIfRemoved(resolution: resolution)
                
                return .none
                
            case .destination: return .none
                
                
                
            // Move Actions
                
            case .movedLanguage(fromOffsets: let fromOffsets, toOffset: let toOffset):
                
                state.model.moveLanguages(onEntry: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            case .movedTranslation(fromOffsets: let fromOffsets, toOffset: let toOffset):
                
                state.model.moveTranslations(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            case .movedUsage(fromOffsets: let fromOffsets, toOffset: let toOffset):
                
                state.model.moveUsages(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            case .movedNote(fromOffsets: let fromOffsets, toOffset: let toOffset):
                
                state.model.moveNotes(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Language: CategorizedItem {
    public var value: String {
        @Shared(.model) var model
        return model.displayName(for: self)
    }
}

extension Entry: CategorizedItem {
    public var value: String { spelling }
}

extension Usage: CategorizedItem {}
extension Language: CategorizedItemsSectionCategory {
    public var title: String {
        @Shared(.model) var model
        return model.displayName(for: self)
    }
}

extension Note: TextEditableItem {}

public struct EntryDetailView: View {
    
    public init(store: StoreOf<EntryDetail>) {
        self.store = store
    }
    
    @Bindable var store: StoreOf<EntryDetail>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
    }
    
    @Environment(\.entryDetail) private var style
        
    public var body: some View {
        Group {
            if let entry = store.entry {
                Form {
                    
                    CategorizedItemsSection(
                        title: "Language",
                        items: store.languages,
                        availableCategories: store.availableLanguages,
                        onSelected: nil,
                        onDeleted: { store.send(.languageCellDestructiveSwipeButtonTapped($0)) },
                        onMoved: { store.send(.movedLanguage(fromOffsets: $0, toOffset: $1)) },
                        onMenuItemTapped: { store.send(.addLanguageMenuButtonTapped($0)) },
                        onMenuShortPressed: nil
                    )

                    CategorizedItemsSection(
                        title: "Translations",
                        items: store.translations,
                        availableCategories: store.availableLanguages,
                        onSelected: { store.send(.translationCellTapped($0)) },
                        onDeleted: { store.send(.translationCellDestructiveSwipeButtonTapped($0)) },
                        onMoved: { store.send(.movedTranslation(fromOffsets: $0, toOffset: $1)) },
                        onMenuItemTapped: { store.send(.addNewCustomLanguageTranslationButtonTapped($0)) },
                        onMenuShortPressed: { store.send(.addNewTranslationButtonTapped) }
                    )

                    CategorizedItemsSection(
                        title: "Usages",
                        items: store.usages,
                        availableCategories: store.availableLanguages,
                        onSelected: nil, //{ store.send(.usageCellTapped($0)) },
                        onDeleted: { store.send(.usageCellDestructiveSwipeButtonTapped($0)) },
                        onMoved: { store.send(.movedUsage(fromOffsets: $0, toOffset: $1)) },
                        onMenuItemTapped: { store.send(.addNewCustomLanguageUsageButtonTapped($0)) },
                        onMenuShortPressed: { store.send(.addNewUsageButtonTapped) }
                    )

                    TextEditableItemsSection(
                        title: "Notes",
                        items: store.notes,
                        onSelected: nil, // { store.send(.noteCellTapped($0)) },
                        onDeleted: { store.send(.noteCellDestructiveSwipeButtonTapped($0)) },
                        onMoved: { store.send(.movedNote(fromOffsets: $0, toOffset: $1)) },
                        onMenuShortPressed: { store.send(.addNewNoteButtonTapped) }
                    )

                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(entry.spelling.capitalized)
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    store.send(.keyboardToolbarDoneButtonTapped)
                }
            }
        }
        .modifier(EntrySpellingEditorToolbarItem(store: store))
        .modifier(
            ToolbarTextFieldInstaller(
                placeholder: store.textField.placeholder,
                language: store.textField.languageOverride ?? store.systemLanguage,
                text: $store.textField.text,
                focused: $store.textField.isFocused,
                installed: store.textField.target != nil,
                onLanguageUnavailable: { store.send(.textInputCouldNotMatchLanguage(id: $0)) },
                onSaveButtonTapped: { store.send(.toolbarTextFieldSaveButtonTapped) },
                onSubmit: { store.send(.toolbarTextFieldSubmitted) },
                tappedViewBehindActiveToolbarTextField: { store.send(.tappedOutsideActiveToolbarTextField) }
            )
        )
        .safeAreaPadding(.bottom, 12)
        .environment(\.toolbarTextField.autocapitalization, store.textField.autocapitalization)
        .task { await store.send(.task).finish() }
    }
}

struct EntrySpellingEditorToolbarItem: ViewModifier {
    
    let store: StoreOf<EntryDetail>
        
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        store.send(.editSpellingButtonTapped)
                    }
                }
            }
    }
}

struct EntryDetailDestinations: ViewModifier {
    
    let store: StoreOf<EntryDetail>
        
    func body(content: Content) -> some View {
        content
            .confirmationDialog(store: store.scope(
                state: \.$destination.spellingUpdateConflict,
                action: \.destination.spellingUpdateConflict
            ))
            .confirmationDialog(store: store.scope(
                state: \.$destination.newTranslationSpellingConflict,
                action: \.destination.newTranslationSpellingConflict
            ))
            .alert(store: store.scope(
                state: \.$destination.keyboardUnavailable,
                action: \.destination.keyboardUnavailable
            ))
            .alert(store: store.scope(
                state: \.$destination.emptyUsageResolution,
                action: \.destination.emptyUsageResolution
            ))
            .alert(store: store.scope(
                state: \.$destination.emptyNoteResolution,
                action: \.destination.emptyNoteResolution
            ))
            .alert(store: store.scope(
                state: \.$destination.orphanedIfRemoved,
                action: \.destination.orphanedIfRemoved
            ))
    }
}



extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}

#Preview {
    @Shared(.model) var model = .mock(entries: 0..<10, created: .now)
    return EntryDetailView(
        store: .init(
            initialState: .init(
                entry: .mock(0),
                translationsEditorFocused: false
            ),
            reducer: { EntryDetail()._printChanges() }
        )
    )
}
