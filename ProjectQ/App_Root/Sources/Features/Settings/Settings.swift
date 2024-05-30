
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct SettingsEditor {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.settings) var settings
    }
    
    public enum Action {
        case destructiveSwipeButtonTapped(Language)
        case addLanguageMenuButtonTapped(Language)
        case languageSelected(Language)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destructiveSwipeButtonTapped(let selected):
                
                state.settings.languageSelectionList.removeAll(where: { $0 == selected })
                
                return .none
                
            case .addLanguageMenuButtonTapped(let selected):
                
                state.settings.languageSelectionList.append(selected)
                state.settings.focusedLanguage = selected
                
                return .none

            case .languageSelected(let selected):
                
                state.settings.focusedLanguage = selected
                
                return .none
                
            case .moved(let fromOffsets, let toOffset):
                                
                state.settings.languageSelectionList.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            }
        }
    }
}

struct SettingsEditorView: View {
    
    @Bindable var store: StoreOf<SettingsEditor>
        
    var body: some View {
        List {
            Section {
                ForEach(store.settings.languageSelectionList) { item in
                    HStack {
                        Button(action: { store.send(.languageSelected(item)) }) {
                            Text(item.displayName.capitalized)
                        }
                        Spacer()
                        Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button(
                            role: .destructive,
                            action: {
                                store.send(.destructiveSwipeButtonTapped(item))
                            },
                            label: {
                                Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                            }
                        )
                    }
                }
                .onMove { from, to in
                    store.send(.moved(fromOffsets: from, toOffset: to))
                }
            } header: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Languages")
                    Spacer()
                    Menu {
                        ForEach(store.settings.languageSelectionList) { availableLanguage in
                            Button(action: { store.send(.addLanguageMenuButtonTapped(availableLanguage)) }) {
                                Text(availableLanguage.displayName)
                                    .textCase(.none)
                            }
                        }
                    } label: {
                        Text("+ add")
                            .font(.callout)
                            .textCase(.lowercase)
                    }
                }
            }
        }
    }
}


#Preview { Preview }
private var Preview: some View {
    SettingsEditorView(store: .init(initialState: .init(), reducer: { SettingsEditor() }))
}
