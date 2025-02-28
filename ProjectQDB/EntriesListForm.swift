////
////  EntriesListForm.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import Dependencies
//import GRDB
//import IssueReporting
//import SwiftUI
//
//struct EntriesListForm: View {
//    @Dependency(\.defaultDatabase) private var database
//
//    @State var entryCollection: EntryCollection
//    @Environment(\.dismiss) var dismiss
//
//    init(existingList: EntryCollection? = nil) {
//        if let existingList {
//            entryCollection = existingList
//        } else {
//            entryCollection = EntryCollection()
//        }
//    }
//
//    var body: some View {
//        Form {
//            TextField("Name", text: $entryCollection.title)
//        }
//        .toolbar {
//            ToolbarItem {
//                Button("Save") {
//                    withErrorReporting {
//                        do {
//                            try database.write { db in
//                                _ = try entryCollection.saved(db)
//                            }
//                        }
//                    }
//                    dismiss()
//                }
//            }
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") {
//                    dismiss()
//                }
//            }
//        }
//    }
//}
//
//extension Int {
//    fileprivate var cgColor: CGColor {
//        get {
//            CGColor(
//                red: Double((self >> 16) & 0xFF) / 255.0,
//                green: Double((self >> 8) & 0xFF) / 255.0,
//                blue: Double(self & 0xFF) / 255.0,
//                alpha: 1
//            )
//        }
//        set {
//            guard let components = newValue.components
//            else { return }
//            self = (Int(components[0] * 255) << 16)
//            | (Int(components[1] * 255) << 8)
//            | Int(components[2] * 255)
//        }
//    }
//}
//
//#Preview {
//    let _ = DB.prepareForPreviews()
//    NavigationStack {
//        EntriesListForm()
//    }
//}
