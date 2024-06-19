//
//import AppModel
//import ComposableArchitecture
//import Foundation
//import StructuralModel
//import SwiftUI
//
//@Reducer
//public struct EntrySpellingEditor {
//    
//    @ObservableState
//    public struct State: Equatable {
//        
//        init(entryID: Shared<Entry.ID>) {
//            self._entryID = entryID
//            self.textField = .init(matching: .entry(entryID.wrappedValue))
//        }
//        
//        @Shared(.model) var model
//        
//        @Shared var entryID: Entry.ID
//        var textField: ToolbarTextField.State
//        
//        @Presents var destination: Destination.State?
//        
//
//
//    }
//    
//    @Reducer(state: .equatable)
//    public enum Destination {
//        case alert(AlertState<Never>)
//        case confirmationDialog(ConfirmationDialogState<EntrySpellingEditor.ConfirmationDialog>)
//    }
//    
//    public enum ConfirmationDialog: Equatable {
//        case cancel
//        case mergeWithExistingSpellingMatch(Entry)
//        case updateSpellingWithoutMerging
//    }
//
//    public enum Action {
//        case destination(PresentationAction<Destination.Action>)
//        case textField(ToolbarTextField.Action)
//        
//        case editSpellingButtonTapped
//    }
//
//    public var body: some ReducerOf<Self> {
//        
//        Scope(state: \.textField, action: \.textField) {
//            ToolbarTextField()
//        }
//        
//        Reduce<State, Action> { state, action in
//            switch action {
//            }
//        }
//        .ifLet(\.$destination, action: \.destination)
//    }
//}
//
//
