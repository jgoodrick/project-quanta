
import ComposableArchitecture
import Foundation
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct UsageDetail {
    
    @ObservableState
    public struct State: Equatable {
                
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        let id: Usage.ID
        var languageEditor: LanguageEditor.State

        @Presents var destination: Destination.State?

        var usage: Usage? {
            db[usage: id]
        }

    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case entryDetail(EntryDetail)
        case usageDetail(UsageDetail)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case languageEditor(LanguageEditor.Action)
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .languageEditor: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct UsageDetailView: View {
    
    @Bindable var store: StoreOf<UsageDetail>
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
    }
    
    @Environment(\.usageDetail) private var style
    
    var languagesStore: StoreOf<LanguageEditor> { store.scope(state: \.languageEditor, action: \.languageEditor) }
    
    public var body: some View {
        Group {
            if let usage = store.usage {
                Form {
                    
                    CategorizedItemsSection(
                        title: "Language",
                        items: languagesStore.languages,
                        availableCategories: languagesStore.settings.languageSelectionList.map({ $0 }),
                        onSelected: nil,
                        onDeleted: { languagesStore.send(.destructiveSwipeButtonTapped($0)) },
                        onMoved: { languagesStore.send(.moved(fromOffsets: $0, toOffset: $1)) },
                        onMenuItemTapped: {
                            languagesStore.send(.addMenuButtonTapped($0))
                        },
                        onMenuShortPressed: nil
                    )

//                    EntryTranslationsEditorView(store: store.scope(state: \.translationsEditor, action: \.translationsEditor))
                    
                }
//                .modifier(EntrySpellingEditorViewModifier(store: store.scope(state: \.spellingEditor, action: \.spellingEditor)))
//                .modifier(FloatingTextFieldInset(store: store.scope(state: \.translationsEditor.textField, action: \.translationsEditor.textField)))
//                .modifier(FloatingTextFieldInset(store: store.scope(state: \.translationsEditor.textField, action: \.translationsEditor.textField)))
                .navigationTitle(usage.value)
            } else {
                ContentUnavailableView("Missing Usage", systemImage: "nosign")
            }
        }
//        .scrollContentBackground(.hidden)
        .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) { store in
            EntryDetailView(store: store)
        }
        .navigationDestination(item: $store.scope(state: \.destination?.usageDetail, action: \.destination.usageDetail)) { store in
            UsageDetailView(store: store)
        }
    }
}

extension EnvironmentValues {
    public var usageDetail: UsageDetailView.Style {
        get { self[UsageDetailView.Style.self] }
        set { self[UsageDetailView.Style.self] = newValue }
    }
}
