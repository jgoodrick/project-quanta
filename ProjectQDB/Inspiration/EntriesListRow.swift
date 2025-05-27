////
////  EntriesListRow.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import SharingGRDB
//import SwiftUI
//
//struct EntriesListRow: View {
//    let entryCount: Int
//    let entryCollection: EntryCollection
//
//    @State var editList: EntryCollection?
//
//    @Dependency(\.defaultDatabase) private var database
//
//    var body: some View {
//        HStack {
//            Image(systemName: "list.bullet.circle.fill")
//                .font(.title)
//            Text(entryCollection.title)
//            Spacer()
//            Text("\(entryCount)")
//        }
//        .swipeActions {
//            Button {
//                withErrorReporting {
//                    _ = try database.write { db in
//                        try entryCollection.delete(db)
//                    }
//                }
//            } label: {
//                Image(systemName: "trash")
//            }
//            .tint(.red)
//            Button {
//                editList = entryCollection
//            } label: {
//                Image(systemName: "info.circle")
//            }
//        }
//        .sheet(item: $editList) { list in
//            NavigationStack {
//                EntriesListForm(existingList: list)
//                    .navigationTitle("Edit list")
//            }
//            .presentationDetents([.medium])
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        List {
//            EntriesListRow(
//                entryCount: 10,
//                entryCollection: EntryCollection(
//                    title: "Personal"
//                )
//            )
//        }
//    }
//}
