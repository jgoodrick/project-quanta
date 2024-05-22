
import ComposableArchitecture
import SwiftUI

@Reducer
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.inputLocales) var inputLocales: [Locale]
        @Shared(.inputLocale) var inputLocale: Locale
        
        var localesAvailableForSelection: [Locale] {
            UITextInputMode.activeInputModes.compactMap({
                guard let primaryLanguage = $0.primaryLanguage else { return nil }
                return Locale(identifier: primaryLanguage)
            })
        }
    }
    
    public enum Action {
        case destructiveSwipeButtonTapped(Locale)
        case addLanguageMenuButtonTapped(Locale)
        case languageSelected(Locale)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destructiveSwipeButtonTapped(let locale):
                
                state.inputLocales.removeAll(where: { $0.identifier == locale.identifier })
                
                return .none
                
            case .addLanguageMenuButtonTapped(let newLocale):
                
                state.inputLocales += [newLocale]
                state.inputLocale = newLocale
                
                return .none

            case .languageSelected(let selected):
                
                state.inputLocale = selected
                
                return .none
                
            case .moved(let fromOffsets, let toOffset):
                                
                state.inputLocales.move(fromOffsets: fromOffsets, toOffset: toOffset)
                
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
                ForEach(store.inputLocales) { inputLocale in
                    HStack {
                        Button(action: { store.send(.languageSelected(inputLocale)) }) {
                            Text(inputLocale.displayName().capitalized)
                        }
                        Spacer()
                        Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button(
                            role: .destructive,
                            action: {
                                store.send(.destructiveSwipeButtonTapped(inputLocale))
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
                        ForEach(store.localesAvailableForSelection) { availableLanguage in
                            Button(action: { store.send(.addLanguageMenuButtonTapped(availableLanguage)) }) {
                                Text(availableLanguage.displayName())
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
