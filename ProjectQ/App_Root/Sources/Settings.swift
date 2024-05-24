
import ComposableArchitecture
import SwiftUI

@Reducer
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.languageSelectionList) var languageSelectionList
        @Shared(.focusedLanguage) var focusedLanguage
    }
    
    public enum Action {
        case destructiveSwipeButtonTapped(LanguageSelection)
        case addLanguageMenuButtonTapped(LanguageSelection)
        case languageSelected(LanguageSelection)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destructiveSwipeButtonTapped(let selected):
                
                state.languageSelectionList.removeAll(where: { $0 == selected })
                
                return .none
                
            case .addLanguageMenuButtonTapped(let selected):
                
                state.languageSelectionList.append(selected)
                state.focusedLanguage = selected
                
                return .none

            case .languageSelected(let selected):
                
                state.focusedLanguage = selected
                
                return .none
                
            case .moved(let fromOffsets, let toOffset):
                                
                state.languageSelectionList.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            }
        }
    }
}

struct SettingsView: View {
    
    @Bindable var store: StoreOf<Settings>
    
    var body: some View {
        List {
            Section {
                ForEach(store.languageSelectionList) { item in
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
                        ForEach(store.languageSelectionList) { availableLanguage in
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
    SettingsView(store: .init(initialState: .init(), reducer: { Settings() }))
}
