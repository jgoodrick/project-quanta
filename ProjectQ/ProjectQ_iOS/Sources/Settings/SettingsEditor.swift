
#if !os(watchOS)

import AppModel
import ComposableArchitecture
import Foundation
import LayoutCore
import StructuralModel
import SwiftUI

@Reducer
struct SettingsEditor {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.model) var model
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Never>)
        case addCustomLanguage(AddCustomLanguage)
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case destructiveSwipeButtonTapped(Language)
        case addLanguageMenuItemSelected(Language)
        case addCustomLanguageMenuItemTapped
        case languageListItemTapped(Language)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination: return .none
            case .destructiveSwipeButtonTapped(let selected):
                
                state.model.settings.languageSelectionList.removeAll(where: { $0 == selected })
                
                // if the focused language is the one that was just removed, default it to the top language:
                
                if state.model.settings.defaultNewEntryLanguage == selected {
                    if let topLanguage = state.model.settings.languageSelectionList.first {
                        state.model.settings.defaultNewEntryLanguage = topLanguage
                    } else {
                        @Dependency(\.systemLanguages) var systemLanguages
                        state.model.settings.defaultNewEntryLanguage = systemLanguages.current()
                    }
                }
                
                return .none
                
            case .addLanguageMenuItemSelected(let selected):
                
                state.model.ensureExistenceOf(language: selected)
                state.model.settings.languageSelectionList.append(selected)
                state.model.settings.defaultNewEntryLanguage = selected

                return .none

            case .addCustomLanguageMenuItemTapped:
                
                state.destination = .addCustomLanguage(.init())
                
                return .none
                
            case .languageListItemTapped(let selected):
                
                state.model.settings.defaultNewEntryLanguage = selected
                
                return .none
                
            case .moved(let fromOffsets, let toOffset):
                                
                state.model.settings.languageSelectionList.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

fileprivate extension AlertState where Action == Never {
    static func failedToAddLanguage(_ language: Language) -> Self {
        .init(title: { .init("Failed to add \(language/*.displayName*/)")})
    }
}

struct SettingsEditorView: View {
    
    @Bindable var store: StoreOf<SettingsEditor>
        
    var body: some View {
        List {
            Section {
                ForEach(store.model.settings.languageSelectionList) { language in
                    HStack {
//                        Button(action: { store.send(.languageListItemTapped(language)) }) {
//                            Text("language.displayName(locale: .current)".capitalized)
//                        }
//                        Spacer()
//                        Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                    }
                    .modifier(DeleteSwipeAction_tvOS_excluded {
                        store.send(.destructiveSwipeButtonTapped(language))
                    })
                }
                .onMove { from, to in
                    store.send(.moved(fromOffsets: from, toOffset: to))
                }
            } header: {
                
                HStack(alignment: .firstTextBaseline) {
                    
                    Text("Languages")
                    
                    Spacer()
                    
                    Menu {
//                        ForEach(store.model.settings.additionalLanguagesAvailable) { availableLanguage in
//                            Button(action: { store.send(.addLanguageMenuItemSelected(availableLanguage)) }) {
//                                Text("availableLanguage.displayName")
//                                    .textCase(.none)
//                            }
//                        }
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

#endif
