////
////  EntryForm.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import Dependencies
//import GRDB
//import IssueReporting
//import Sharing
//import SharingGRDB
//import SwiftUI
//
//struct EntryFormView: View {
//    @SharedReader(.fetchAll(sql: #"SELECT * FROM "entryCollections" ORDER BY "spelling" ASC"#))
//    var entryCollections: [EntryCollection]
//
//    @State var isPresentingTagsPopover = false
//    @State var entryCollection: EntryCollection
//    @State var entry: Entry
//    @State var selectedTags: [Tag] = []
//
//    @Dependency(\.defaultDatabase) private var database
//    @Environment(\.dismiss) var dismiss
//
//    init?(existingEntry: Entry? = nil, entryCollection: EntryCollection) {
//        self.entryCollection = entryCollection
//        if let existingEntry {
//            entry = existingEntry
//        } else if let _ = entryCollection.id {
//            entry = Entry()
//        } else {
//            reportIssue("'list.id' is required to be non-nil.")
//            return nil
//        }
//    }
//
//    var body: some View {
//        Form {
//            TextField("Title", text: $entry.spelling)
//
//            Section {
//                Button {
//                    isPresentingTagsPopover = true
//                } label: {
//                    HStack {
//                        Image(systemName: "number.square.fill")
//                            .font(.title)
//                            .foregroundStyle(.gray)
//                        Text("Tags")
//                            .foregroundStyle(.black)
//                        Spacer()
//                        tagsDetail
//                            .lineLimit(1)
//                            .truncationMode(.tail)
//                            .font(.callout)
//                            .foregroundStyle(.gray)
//                        Image(systemName: "chevron.right")
//                    }
//                }
//            }
//            .popover(isPresented: $isPresentingTagsPopover) {
//                NavigationStack {
//                    TagsView(selectedTags: $selectedTags)
//                }
//            }
//
//            Section {
////                Picker(selection: $entryCollection) {
////                    ForEach(entryCollections) { entryCollection in
////                        Text(entryCollection.spelling)
////                            .tag(entryCollection)
////                            .buttonStyle(.plain)
////                    }
////                } label: {
//                    Text("List")
////                }
////                .onChange(of: entryCollection) {
////                    entry.listID = entryCollection.id!
////                }
//            }
//        }
//        .task { [entryID = entry.id] in
//            do {
//                selectedTags = try await database.read { db in
//                    try Tag.all()
//                        .joining(optional: Tag.hasMany(Entry_Tag.self))
//                        .filter(Column("entryID").detached == entryID)
//                        .order(Column("spelling"))
//                        .fetchAll(db)
//                }
//            } catch {
//                selectedTags = []
//                reportIssue(error)
//            }
//        }
//        .navigationTitle(entryCollection.title)
//        .toolbar {
//            ToolbarItem {
//                Button(action: saveButtonTapped) {
//                    Text("Save")
//                }
//            }
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") {
//                    dismiss()
//                }
//            }
//        }
//    }
//
//    private var tagsDetail: Text {
//        selectedTags.reduce(Text("")) { result, tag in
//            result + Text("#\(tag.title) ")
//        }
//    }
//
//    private func saveButtonTapped() {
//        withErrorReporting {
//            try database.write { db in
//                try entry.save(db)
//                try Entry_Tag.filter(Column("entryID") == entry.id!).deleteAll(db)
//                for tag in selectedTags {
//                    _ = try Entry_Tag(entryID: entry.id!, tagID: tag.id!).saved(db)
//                }
//            }
//        }
//        dismiss()
//    }
//}
//
//extension Optional {
//    fileprivate subscript(coalesce coalesce: Wrapped) -> Wrapped {
//        get { self ?? coalesce }
//        set { self = newValue }
//    }
//}
//
//#Preview {
//    let (entryCollection, entry) = try! prepareDependencies {
//        $0.defaultDatabase = try ProjectQDB.appDatabase()
//        return try $0.defaultDatabase.write { db in
//            let entryCollection = try EntryCollection.fetchOne(db)!
//            return (
//                entryCollection,
//                try Entry.filter(Column("listID") == entryCollection.id).fetchOne(db)!
//            )
//        }
//    }
//    NavigationStack {
//        EntryFormView(existingEntry: entry, entryCollection: entryCollection)
//    }
//}
