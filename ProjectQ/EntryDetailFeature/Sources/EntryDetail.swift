
import ComposableArchitecture
import Foundation
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct EntryDetail {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        public init(entry entryID: Entry.ID) {
            let shared = Shared(entryID)
            self._entryID = shared
            self.spellingEditor = .init(entryID: shared)
            self.languageEditor = .init(entity: .entry(shared.wrappedValue))
            self.translationsEditor = .init(entryID: shared)
            self.usagesEditor = .init(entryID: shared)
            self.notesEditor = .init(entryID: shared)
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var spellingEditor: EntrySpellingEditor.State
        var languageEditor: LanguageEditor.State
        var translationsEditor: EntryTranslationsEditor.State
        var usagesEditor: EntryUsagesEditor.State
        var notesEditor: EntryNotesEditor.State
        
        @Presents var destination: Destination.State?

        var entry: Entry? {
            db[entry: entryID]
        }

    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case translationDetail(EntryDetail)
        case usageDetail(UsageDetail)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spellingEditor(EntrySpellingEditor.Action)
        case languageEditor(LanguageEditor.Action)
        case translationsEditor(EntryTranslationsEditor.Action)
        case usagesEditor(EntryUsagesEditor.Action)
        case notesEditor(EntryNotesEditor.Action)
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.languageEditor, action: \.languageEditor) {
            LanguageEditor()
        }

        Scope(state: \.spellingEditor, action: \.spellingEditor) {
            EntrySpellingEditor()
        }
        
        Scope(state: \.translationsEditor, action: \.translationsEditor) {
            EntryTranslationsEditor()
        }
        
        Scope(state: \.usagesEditor, action: \.usagesEditor) {
            EntryUsagesEditor()
        }
        
        Scope(state: \.notesEditor, action: \.notesEditor) {
            EntryNotesEditor()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .spellingEditor: return .none
            case .languageEditor: return .none
            case .translationsEditor(.delegate(let delegateAction)):
                switch delegateAction {
                case .selected(let translation):

                    state.destination = .translationDetail(.init(entry: translation.id))

                    return .none

                }
            case .translationsEditor: return .none
            case .usagesEditor(.delegate(let delegateAction)):
                switch delegateAction {
                case .selected(let usage):
                    
                    state.destination = .usageDetail(.init(id: usage.id, languageEditor: .init(entity: .usage(usage.id))))
                    
                    return .none
                    
                }
            case .usagesEditor: return .none
            case .notesEditor: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct EntryDetailView: View {
    
    public init(store: StoreOf<EntryDetail>) {
        self.store = store
    }
    
    @SwiftUI.Bindable var store: StoreOf<EntryDetail>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
    }
    
    @Environment(\.entryDetail) private var style
        
    public var body: some View {
        Group {
            if let entry = store.entry {
                Form {
                    
                    LanguageEditorView(
                        store: store.scope(state: \.languageEditor, action: \.languageEditor)
                    )

                    EntryTranslationsEditorView(
                        store: store.scope(state: \.translationsEditor, action: \.translationsEditor)
                    )

                    EntryUsagesEditorView(
                        store: store.scope(state: \.usagesEditor, action: \.usagesEditor)
                    )

                    EntryNotesEditorView(
                        store: store.scope(state: \.notesEditor, action: \.notesEditor)
                    )

                }
                .modifier(
                    EntrySpellingEditorViewModifier(
                        store: store.scope(state: \.spellingEditor, action: \.spellingEditor),
                        placeholder: "Provide the spelling"
                    )
                )
                .modifier(
                    FloatingTextFieldInset(
                        store: store.scope(state: \.translationsEditor.textField, action: \.translationsEditor.textField),
                        placeholder: "Add a \(store.translationsEditor.textField.language.displayName) translation"
                    )
                )
                .modifier(
                    FloatingTextFieldInset(
                        store: store.scope(state: \.usagesEditor.textField, action: \.usagesEditor.textField),
                        placeholder: "Add an example sentence",
                        autocapitalization: .sentences
                    )
                )
                .modifier(
                    FloatingTextFieldInset(
                        store: store.scope(state: \.notesEditor.textField, action: \.notesEditor.textField),
                        placeholder: "Add a note about this word",
                        autocapitalization: .sentences
                    )
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        // this toolbar has to live here due to a SwiftUI bug that only allows one toolbar modifier for a form
                        Button("Done") {
                            store.send(.notesEditor(.doneButtonTapped))
                        }
                    }
                }
                .navigationTitle(entry.spelling.capitalized)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.translationDetail, action: \.destination.translationDetail)) { store in
            EntryDetailView(store: store)
        }
        .safeAreaPadding(.bottom, 12)
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
