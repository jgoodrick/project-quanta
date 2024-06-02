
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryDetail {
    
    @ObservableState
    public struct State: Equatable {
        
        init(entry entryID: Entry.ID) {
            let shared = Shared(entryID)
            self._entryID = shared
            self.spellingEditor = .init(entryID: shared)
            self.translationsEditor = .init(entryID: shared)
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var spellingEditor: EntrySpellingEditor.State
        var translationsEditor: EntryTranslationsEditor.State
        
        @Presents var destination: Destination.State?

        var languageName: String {
            $db[entry: entryID]?.language?.displayName ?? "Not Set"
        }

        var entry: Entry? {
            db[entry: entryID]
        }

    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case translationDetail(EntryDetail)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spellingEditor(EntrySpellingEditor.Action)
        case translationsEditor(EntryTranslationsEditor.Action)
        
        case editLanguageMenuButtonSelected(Language)
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()

        Scope(state: \.spellingEditor, action: \.spellingEditor) {
            EntrySpellingEditor()
        }
        
        Scope(state: \.translationsEditor, action: \.translationsEditor) {
            EntryTranslationsEditor()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .spellingEditor: return .none
            case .translationsEditor(.delegate(let delegateAction)):
                switch delegateAction {
                case .translationSelected(let translation):

                    state.destination = .translationDetail(.init(entry: translation.id))

                    return .none

                }
            case .translationsEditor: return .none
            case .editLanguageMenuButtonSelected(let selected):

                state.db.updateLanguage(to: selected.id, for: state.entryID)

                return .none

            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct EntryDetailLanguageSectionView: View {
    
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

public struct EntryDetailView: View {
    
    @Bindable var store: StoreOf<EntryDetail>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
    }
    
    @Environment(\.entryDetail) private var style
    
    public var body: some View {
        Group {
            if let entry = store.entry {
                Form {
                    
                    EntryDetailLanguageSectionView(store: store)
        
                    EntryTranslationsEditorView(store: store.scope(state: \.translationsEditor, action: \.translationsEditor))
                    
                }
                .modifier(EntrySpellingEditorViewModifier(store: store.scope(state: \.spellingEditor, action: \.spellingEditor)))
                .modifier(EntryTranslationsEditorViewModifier(store: store.scope(state: \.translationsEditor, action: \.translationsEditor)))
                .navigationTitle(entry.spelling)
            } else {
                ContentUnavailableView("Missing Entry", systemImage: "nosign")
            }
        }
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.translationDetail, action: \.destination.translationDetail)) { store in
            EntryDetailView(store: store)
        }
    }
}

extension EnvironmentValues {
    public var entryDetail: EntryDetailView.Style {
        get { self[EntryDetailView.Style.self] }
        set { self[EntryDetailView.Style.self] = newValue }
    }
}
