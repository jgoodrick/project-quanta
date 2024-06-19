
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
        
        var toolbarText: String = ""
        var toolbarTextFieldIsFocused: Bool { toolbarTarget != nil }
        var toolbarTarget: ToolbarTarget?
        enum ToolbarTarget: Equatable {
            case spelling(Entry.ID)
            case translation(Entry.ID?)
            case usage(Usage.ID?)
            case note(Note.ID?)
        }
        var shouldLaunchTranslationsEditorImmediately: Bool = false
        var translationLanguageOverride: Language.ID?
        
        @Presents var destination: Destination.State?

        var entry: Entry? {
            model[entry: entryID]
        }

        mutating func resetToolbarTextField(to targeting: ToolbarTarget? = nil) {
            toolbarText = ""
            toolbarTarget = targeting
        }

        mutating func submitText() -> EffectOf<EntryDetail> {
            
            defer {
                resetToolbarTextField()
            }
            
            switch toolbarTarget {
            case .spelling:
                guard !toolbarText.isEmpty else { return .none }

                switch model.updateEntrySpelling(of: entryID, to: toolbarText) {
                case .success, .canceled: break
                case .conflicts(let conflicts):
                    destination = .spellingUpdateConflict(.spellingUpdateMatches(entries: conflicts))
                }
                
            case .translation(let id):
                guard !toolbarText.isEmpty else { return .none }

                if let id {
                    
                } else {
                    switch model.addNewTranslation(fromSpelling: toolbarText, forEntry: entryID) {
                    case .success, .canceled: break
                    case .conflicts(let conflicts):
                        destination = .newTranslationSpellingConflict(.newTranslationSpellingMatches(entries: conflicts))
                    }
                }
                
            case .usage(let id):
                if let id {
                    preconditionFailure("no current use case for a toolbar target of .usage")
                } else {
                    _ = model.addNewUsage(content: toolbarText, toEntry: entryID, valueConflictResolution: .mergeWithFirstMatch)
                }
            case .note(let id):
                guard !toolbarText.isEmpty else { return .none }
                if let id {
                    model.updateNote(\.value, of: id, to: toolbarText)
                } else {
                    _ = model.addNewNote(content: toolbarText, toEntry: entryID)
                }
            case nil:
                preconditionFailure("toolbar target not set when 'submitText()' was called")
            }
            
            return .none
            
        }

    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case entryDetail(EntryDetail)
        case alert(AlertState<Never>)
        case orphanRemoval(ConfirmationDialogState<OrphanRemovalResolution>)
        case spellingUpdateConflict(ConfirmationDialogState<SpellingConflictResolution>)
        case newTranslationSpellingConflict(ConfirmationDialogState<NewTranslationSpellingConflictResolution>)
    }
    
    public struct OrphanRemovalResolution: Equatable {
        let entity: Entity.ID
        let decision: Decision
        public enum Decision {
            case cancel
            case delete
            case disconnectOnly
        }
    }

    public struct SpellingConflictResolution: Equatable {
        let firstMatch: Entry
        let decision: AppModel.AutoConflictResolution
    }
    
    public struct NewTranslationSpellingConflictResolution: Equatable {
        let firstMatch: Entry
        let decision: AppModel.AutoConflictResolution
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)

        // text field
        case textInputCouldNotMatchLanguage(id: String)
        case toolbarTextFieldSaveButtonTapped
        case toolbarTextFieldSubmitted
        case tappedOutsideActiveToolbarTextField

        // language section
        case addLanguageMenuButtonTapped(Language)
        case languageCellDestructiveSwipeButtonTapped(Language)
        case movedLanguage(fromOffsets: IndexSet, toOffset: Int)

        // spelling section
        case editSpellingButtonTapped
        
        // translations section
        case addNewTranslationButtonTapped
        case translationCellTapped(Entry)
        case translationCellDestructiveSwipeButtonTapped(Entry)

        // usage section
        case addNewUsageButtonTapped
        case usageCellTapped(Usage)
        case usageCellDestructiveSwipeButtonTapped(Usage)

        // notes section
        case addNewNoteButtonTapped
        case noteCellTapped(Note)
        case noteCellDestructiveSwipeButtonTapped(Note)

        // lifecycle
        case task
        case navigationAnimationTimerFinished
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .editSpellingButtonTapped:

//                state.toolbarText = state.model[entry: state.entryID]?.spelling ?? ""
//                state.toolbarTarget = .spelling(state.entryID)

                return .none

            case .toolbarTextFieldSubmitted, .toolbarTextFieldSaveButtonTapped:
                
                return state.submitText()
                
            case .destination(.presented(.spellingUpdateConflict(let resolution))):

                let result = state.model.updateEntrySpelling(
                    of: state.entryID,
                    to: resolution.firstMatch.spelling,
                    spellingConflictResolution: resolution.decision
                )
                
                switch result {
                case .canceled: break
                case .conflicts(let conflicts): XCTFail("Unexpected behavior of AppModel.updateEntrySpelling() \(conflicts)")
                case .success(let merged): 
                    // update the detail page to represent the first match, as the current entry has been deleted during merge:
                    state.entryID = merged.id
                }

                return .none

            case .destination(.presented(.newTranslationSpellingConflict(let resolution))):

                let result = state.model.addNewTranslation(
                    fromSpelling: resolution.firstMatch.spelling,
                    in: state.translationLanguageOverride,
                    forEntry: state.entryID,
                    spellingConflictResolution: resolution.decision
                )
                
                switch result {
                case .canceled, .success: break
                case .conflicts(let conflicts): XCTFail("Unexpected behavior of AppModel.addNewTranslation() \(conflicts)")
                }

                return .none

            case .destination: return .none

            case .addLanguageMenuButtonTapped(let language):
                
                state.model.addExisting(language: language.id, toEntry: state.entryID)
                
                return .none
                
            case .languageCellDestructiveSwipeButtonTapped(let language):

                state.model.remove(language: language.id, fromEntry: state.entryID)

                return .none
                
            case .movedLanguage(fromOffsets: let fromOffsets, toOffset: let toOffset):
                
                state.model.moveLanguages(onEntry: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            case .textInputCouldNotMatchLanguage(id: let id):
                // TODO: show alert directing user to system settings (add a keyboard)
                return .none
                
            case .tappedOutsideActiveToolbarTextField:
                
                state.resetToolbarTextField()
                
                return .none

            case .translationCellTapped(let translation):

                state.destination = .entryDetail(.init(
                    entry: translation.id,
                    translationsEditorFocused: false
                ))

                return .none
                
            case .task:
                
                guard state.shouldLaunchTranslationsEditorImmediately else {
                    return .none
                }
                
                return .run { send in
                    @Dependency(\.continuousClock) var clock
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.navigationAnimationTimerFinished)
                }
                
            case .navigationAnimationTimerFinished:
                
                state.toolbarTarget = .translation(.none)
                
                return .none
                
            case .addNewTranslationButtonTapped:
                return .none
            case .addNewUsageButtonTapped:
                return .none
            case .translationCellDestructiveSwipeButtonTapped(let translation):
                return .none
            case .usageCellTapped(let usageID):
                return .none
            case .usageCellDestructiveSwipeButtonTapped(let usage):
                return .none
            case .addNewNoteButtonTapped:
                return .none
            case .noteCellTapped(let noteID):
                return .none
            case .noteCellDestructiveSwipeButtonTapped(let note):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

fileprivate extension Entity {
    var confirmationTitle: String {
        switch self {
        case .entry(let entry): entry.spelling
        case .entryCollection(let entryCollection): entryCollection.title
        case .keyword(let keyword): keyword.title
        case .language(let language): language.bcp47.rawValue
        case .note(let note):
            "\(note.value.prefix(15))\(note.value.count > 15 ? "..." : "")"
        case .usage(let usage):
            "\(usage.value.prefix(15))\(usage.value.count > 15 ? "..." : "")"
        }
    }
}

extension AlertState {
    static func confirmDeletion(of entity: Entity) -> Self where Action == EntryDetail.OrphanRemovalResolution {
        .init(
            title: {
                .init("Delete '\(entity.confirmationTitle)'?")
            },
            actions: {
                ButtonState<Action>.init(
                    role: .destructive, action: .init(entity: entity.id, decision: .delete), label: { .init("Delete") }
                )
                ButtonState<Action>.init(
                    action: .init(entity: entity.id, decision: .disconnectOnly), label: { .init("Disconnect Only") }
                )
                ButtonState<Action>.init(
                    role: .cancel, action: .init(entity: entity.id, decision: .cancel), label: { .init("Cancel") }
                )
            }
        )
    }
}

extension ConfirmationDialogState {
    static func spellingUpdateMatches(entries: [Entry]) -> Self where Action == EntryDetail.SpellingConflictResolution {
        guard let firstMatch = entries.first else { preconditionFailure() }
        return .init(
            title: {
                .init("A word spelled \"\(firstMatch.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .cancel), label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .maintainDistinction), label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .mergeWithFirstMatch), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
    static func newTranslationSpellingMatches(entries: [Entry]) -> Self where Action == EntryDetail.NewTranslationSpellingConflictResolution {
        guard let firstMatch = entries.first else { preconditionFailure() }
        return .init(
            title: {
                .init("A word spelled \"\(firstMatch.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .cancel), label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .maintainDistinction), label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .init(firstMatch: firstMatch, decision: .mergeWithFirstMatch), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
}

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
                    
//                    LanguageEditorView(
//                        store: store.scope(state: \.languageEditor, action: \.languageEditor)
//                    )
//
//                    EntryTranslationsEditorView(
//                        store: store.scope(state: \.translationsEditor, action: \.translationsEditor)
//                    )
//
//                    EntryUsagesEditorView(
//                        store: store.scope(state: \.usagesEditor, action: \.usagesEditor)
//                    )
//
//                    EntryNotesEditorView(
//                        store: store.scope(state: \.notesEditor, action: \.notesEditor)
//                    )

                }
//                .modifier(
//                    EntrySpellingEditorInstaller(
//                        store: store.scope(state: \.spellingEditor, action: \.spellingEditor),
//                        placeholder: "Provide the spelling"
//                    )
//                )
                #if os(iOS)
//                .modifier(
//                    ToolbarTextFieldInstaller(
//                        store: store.scope(state: \.translationsEditor.textField, action: \.translationsEditor.textField),
//                        placeholder: "Add a \(store.translationsEditor.textField.language.displayName) translation"
//                    )
//                )
//                .modifier(
//                    ToolbarTextFieldInstaller(
//                        store: store.scope(state: \.usagesEditor.textField, action: \.usagesEditor.textField),
//                        placeholder: "Add an example sentence",
//                        autocapitalization: .sentences
//                    )
//                )
//                .modifier(
//                    ToolbarTextFieldInstaller(
//                        store: store.scope(state: \.notesEditor.textField, action: \.notesEditor.textField),
//                        placeholder: "Add a note about this word",
//                        autocapitalization: .sentences
//                    )
//                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        // this toolbar has to live here due to a SwiftUI bug that only allows one keyboard toolbar modifier for a form
                        Button("Done") {
//                            store.send(.notesEditor(.doneButtonTapped))
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationTitle(entry.spelling.capitalized)
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
//        .scrollContentBackground(.hidden)
//        .navigationDestination(item: $store.scope(state: \.destination?.translationDetail, action: \.destination.translationDetail)) { store in
//            EntryDetailView(store: store)
//        }
        .modifier(EntrySpellingEditorToolbarItem(store: store))
        .safeAreaPadding(.bottom, 12)
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



extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
