
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
        
        var languageName: String {
            switch entity {
            case .entry(let entryID):
                $db[entry: entryID]?.language?.displayName ?? "Not Set"
            case .usage(let usageID):
                $db[usage: usageID]?.language?.displayName ?? "Not Set"
            }
        }

    }
    
    public enum Action {
        case editLanguageMenuButtonSelected(Language)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .editLanguageMenuButtonSelected(let selected):
                
                switch state.entity {
                case .entry(let entryID):
                    state.db.updateEntryLanguage(to: selected.id, for: entryID)
                case .usage(let usageID):
                    state.db.updateUsageLanguage(to: selected.id, for: usageID)
                }
                
                return .none
            }
        }
    }
}

struct LanguageEditorView: View {
    
    let store: StoreOf<LanguageEditor>
        
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


