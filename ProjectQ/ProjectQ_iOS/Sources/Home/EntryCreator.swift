//
//import AppModel
//import ComposableArchitecture
//import Foundation
//import LayoutCore
//import StructuralModel
//import SwiftUI
//
//@Reducer
//public struct EntryCreationEditor {
//    
//    @ObservableState
//    public struct State: Equatable {
//        public init() {}
//        
//    }
//    
//    @Reducer(state: .equatable)
//    public enum Destination {
//        case alert(AlertState<Never>)
//        case entryDetail(EntryDetail)
//    }
//
//    public enum Action: BindableAction {
//        case binding(BindingAction<State>)
//        case destination(PresentationAction<Destination.Action>)
////        case spelling(ToolbarTextField.Action)
//    }
//    
//    public var body: some Reducer<State, Action> {
//        
//        BindingReducer()
//        
////        Scope(state: \.spelling, action: \.spelling) {
////            ToolbarTextField()
////        }
//        
//        Reduce<State, Action> { state, action in
//            switch action {
//            case .binding: return .none
////            case .shouldPushDetail(let id, let translationsEditorFocused):
////                
////                state.destination = .entryDetail(.init(
////                    entry: id,
////                    translationsEditorFocused: translationsEditorFocused
////                ))
////                
////                return .none
////                
////            case .spelling(.delegate(let delegatedAction)):
////                switch delegatedAction {
////                case .fieldCommitted, .saveEntryButtonTapped:
////                    
////                    let spelling = state.spelling.text
////                    
////                    guard !spelling.isEmpty else {
////                        state.spelling.reset()
////                        return .none
////                    }
////                    
////                    if let match = state.model.firstEntry(where: { $0.spelling == spelling }) {
////
////                        state.destination = .confirmationDialog(.addOrEditExisting(entry: match))
////
////                        return .none
////
////                    } else {
////                        
////                        return state.addAndPushNewEntry()
////                        
////                    }
////                    
////                }
////            case .spelling: return .none
//            case .destination(.presented(.confirmationDialog(.addNew))):
//                
////                return state.addAndPushNewEntry()
//                return .none
//
//            case .destination(.presented(.confirmationDialog(.editExisting(_/*let existing*/)))):
//                                
////                return state.resetSpellingAndPush(entry: existing.id, translationsEditorFocused: false)
//                return .none
//
//            case .destination: return .none
//            }
//        }
//        .ifLet(\.$destination, action: \.destination)
//    }
//}
//
//
//public struct EntryCreationEditorInstaller: ViewModifier {
//    
//    @Bindable var store: StoreOf<EntryCreationEditor>
//    
//    @Environment(\.isSearching) var isSearching
//    
//    public func body(content: Content) -> some View {
//        content
////            #if os(iOS)
////            .safeAreaInset(edge: .bottom) {
////                if !isSearching {
////                    ToolbarTextFieldView(
////                        store: store.scope(state: \.spelling, action: \.spelling),
////                        placeholder: "New Entry"
////                    )
////                    .padding()
////                    .padding()
////                }
////            }
////            #endif
//            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
//            .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
//            .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) {
//                EntryDetailView(store: $0)
//            }
//    }
//}
//
//#Preview { Preview }
//private var Preview: some View {
//    Color.red.modifier(
//        EntryCreationEditorInstaller(store: .init(initialState: .init(), reducer: { EntryCreationEditor() }))
//    )
//}
