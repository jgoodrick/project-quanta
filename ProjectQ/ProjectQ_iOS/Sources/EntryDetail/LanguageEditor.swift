//
//import AppModel
//import ComposableArchitecture
//import Foundation
//import LayoutCore
//import StructuralModel
//import SwiftUI
//
//@Reducer
//struct LanguageEditor {
//    
//    @ObservableState
//    struct State: Equatable {
//        @Shared(.model) var model
//        var entity: TranslatableEntity
//        
//        var languages: [Language] {
//            model.languages(for: entity)
//        }
//
//    }
//    
//    enum Action {
//    }
//    
//    var body: some ReducerOf<Self> {
//        Reduce<State, Action> { state, action in
//            switch action {
//            case .addMenuButtonTapped(let selected):
//
////                switch state.entity {
////                case .entry(let entryID):
////                    state.model.connect(language: selected.id, toEntry: entryID)
////                case .usage(let usageID):
////                    state.model.connect(language: selected.id, toUsage: usageID)
////                }
//                
//                return .none
//
//            case .destructiveSwipeButtonTapped(let selected):
//
////                switch state.entity {
////                case .entry(let entryID):
////                    state.model.disconnect(language: selected.id, fromEntry: entryID)
////                case .usage(let usageID):
////                    state.model.disconnect(language: selected.id, fromUsage: usageID)
////                }
//
//                return .none
//                
//            case .moved(let fromOffsets, let toOffset):
//
////                switch state.entity {
////                case .entry(let entryID):
////                    state.model.moveLanguages(onEntry: entryID, fromOffsets: fromOffsets, toOffset: toOffset)
////                case .usage(let usageID):
////                    state.model.moveLanguages(onUsage: usageID, fromOffsets: fromOffsets, toOffset: toOffset)
////                }
//
//                return .none
//
//            }
//        }
//    }
//}
//
//extension Language: CategorizedItem {
//    public var value: String {
//        @Shared(.model) var model
//        return model.displayName(for: self)
//    }
//}
//
//struct LanguageEditorView: View {
//    
//    let store: StoreOf<LanguageEditor>
//        
//    var body: some View {
//        Text("Language Editor View")
////        CategorizedItemsSection(
////            title: "Language",
////            items: store.languages,
////            availableCategories: store.model.settings.languageSelectionList.map({ $0 }),
////            onSelected: nil,
////            onDeleted: { store.send(.destructiveSwipeButtonTapped($0)) },
////            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
////            onMenuItemTapped: { store.send(.addMenuButtonTapped($0)) },
////            onMenuShortPressed: nil
////        )
//    }
//}
//
//
