
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct SettingsEditor {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.db) var db
        @Shared(.settings) var settings
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case addCustomLanguage(AddCustomLanguage)
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case destructiveSwipeButtonTapped(Language)
        case addLanguageMenuItemSelected(Language)
        case addCustomLanguageMenuItemTapped
        case languageListItemTapped(Language)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination: return .none
            case .destructiveSwipeButtonTapped(let selected):
                
                state.settings.languageSelectionList.removeAll(where: { $0 == selected })
                
                // if the focused language is the one that was just removed, default it to the top language:
                
                if state.settings.focusedLanguage == selected {
                    if let topLanguage = state.settings.languageSelectionList.first {
                        state.settings.focusedLanguage = topLanguage
                    } else {
                        @Dependency(\.systemLanguages) var systemLanguages
                        state.settings.focusedLanguage = systemLanguages.current()
                    }
                }
                
                return .none
                
            case .addLanguageMenuItemSelected(let selected):
                
                do {
                    try state.db.ensureExistenceOf(language: selected)
                    state.settings.languageSelectionList.append(selected)
                    state.settings.focusedLanguage = selected
                } catch {
                    state.destination = .alert(.failedToAddLanguage(selected))
                }

                return .none

            case .addCustomLanguageMenuItemTapped:
                
                state.destination = .addCustomLanguage(.init())
                
                return .none
                
            case .languageListItemTapped(let selected):
                
                state.settings.focusedLanguage = selected
                
                return .none
                
            case .moved(let fromOffsets, let toOffset):
                                
                state.settings.languageSelectionList.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == Never {
    static func failedToAddLanguage(_ language: Language) -> Self {
        .init(title: { .init("Failed to add \(language.displayName)")})
    }
}

struct SettingsEditorView: View {
    
    @Bindable var store: StoreOf<SettingsEditor>
        
    var body: some View {
        List {
            Section {
                ForEach(store.settings.languageSelectionList) { item in
                    HStack {
                        Button(action: { store.send(.languageListItemTapped(item)) }) {
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
                        ForEach(store.settings.additionalLanguagesAvailable) { availableLanguage in
                            Button(action: { store.send(.addLanguageMenuItemSelected(availableLanguage)) }) {
                                Text(availableLanguage.displayName)
                                    .textCase(.none)
                            }
                        }
                        Button(action: { store.send(.addCustomLanguageMenuItemTapped) }) {
                            Text("Add Custom Language")
                                .textCase(.none)
                        }
                    } label: {
                        Text("+ add")
                            .font(.callout)
                            .textCase(.lowercase)
                    }
                    
                }
                
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(item: $store.scope(state: \.destination?.addCustomLanguage, action: \.destination.addCustomLanguage)) { scoped in
            AddCustomLanguageView(store: scoped)
        }
    }
}


#Preview { Preview }
private var Preview: some View {
    SettingsEditorView(store: .init(initialState: .init(), reducer: { SettingsEditor() }))
}
