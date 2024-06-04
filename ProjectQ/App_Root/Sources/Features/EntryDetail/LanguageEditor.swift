
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct LanguageEditor {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.db) var db
        @Shared(.settings) var settings
        var entity: TranslatableEntity
        enum TranslatableEntity: Equatable {
            case entry(Entry.ID)
            case usage(Usage.ID)
        }
        
        var languages: [Language] {
            switch entity {
            case .entry(let entryID):
                $db[entry: entryID]?.languages ?? []
            case .usage(let usageID):
                $db[usage: usageID]?.languages ?? []
            }
        }

    }
    
    public enum Action {
        case addMenuButtonTapped(Language)
        case destructiveSwipeButtonTapped(Language)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addMenuButtonTapped(let selected):

                switch state.entity {
                case .entry(let entryID):
                    state.db.add(language: selected.id, toEntry: entryID)
                case .usage(let usageID):
                    state.db.add(language: selected.id, toUsage: usageID)
                }
                
                return .none

            case .destructiveSwipeButtonTapped(let selected):

                switch state.entity {
                case .entry(let entryID):
                    state.db.remove(language: selected.id, fromEntry: entryID)
                case .usage(let usageID):
                    state.db.remove(language: selected.id, fromUsage: usageID)
                }

                return .none
                
            case .moved(let fromOffsets, let toOffset):

                switch state.entity {
                case .entry(let entryID):
                    state.db.moveLanguages(onEntry: entryID, fromOffsets: fromOffsets, toOffset: toOffset)
                case .usage(let usageID):
                    state.db.moveLanguages(onUsage: usageID, fromOffsets: fromOffsets, toOffset: toOffset)
                }

                return .none

            }
        }
    }
}

extension Language: CategorizedItem {
    var value: String { displayName }
}

struct LanguageEditorView: View {
    
    let store: StoreOf<LanguageEditor>
        
    var body: some View {
        CategorizedItemsSection(
            title: "Language",
            items: store.languages,
            availableCategories: store.settings.languageSelectionList.map({ $0 }),
            onSelected: nil,
            onDeleted: { store.send(.destructiveSwipeButtonTapped($0)) },
            onMoved: { from, to in
                store.send(.moved(fromOffsets: from, toOffset: to))
            },
            onMenuItemTapped: {
                store.send(.addMenuButtonTapped($0))
            },
            onMenuShortPressed: nil
        )
    }
}


