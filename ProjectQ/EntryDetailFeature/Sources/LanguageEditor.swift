
import ComposableArchitecture
import FeatureCore
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct LanguageEditor {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.db) var db
        @Shared(.settings) var settings
        var entity: TranslatableEntity
        
        var languages: [Language] {
            db.languages(for: entity)
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
                    state.db.connect(language: selected.id, toEntry: entryID)
                case .usage(let usageID):
                    state.db.connect(language: selected.id, toUsage: usageID)
                }
                
                return .none

            case .destructiveSwipeButtonTapped(let selected):

                switch state.entity {
                case .entry(let entryID):
                    state.db.disconnect(language: selected.id, fromEntry: entryID)
                case .usage(let usageID):
                    state.db.disconnect(language: selected.id, fromUsage: usageID)
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
    public var value: String { displayName }
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
            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
            onMenuItemTapped: { store.send(.addMenuButtonTapped($0)) },
            onMenuShortPressed: nil
        )
    }
}


