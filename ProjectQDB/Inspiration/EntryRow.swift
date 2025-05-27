////
////  EntryRow.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import Dependencies
//import SwiftUI
//
//struct EntryRow: View {
//    let isPastDue: Bool
//    let entry: Entry
//    let entryCollection: EntryCollection
//    let tags: [String]
//
//    @State var editEntry: Entry?
//
//    @Dependency(\.defaultDatabase) private var database
//
//    var body: some View {
//        HStack {
//            HStack(alignment: .top) {
////                Button(action: completeButtonTapped) {
////                    Image(systemName: entry.isCompleted ? "circle.inset.filled": "circle")
////                        .foregroundStyle(.gray)
////                        .font(.title2)
////                        .padding([.trailing], 5)
////                }
//                VStack(alignment: .leading) {
//                    title(for: entry)
//
////                    let notes = entry.notes
////                        .split(separator: "\n", omittingEmptySubsequences: true)
////                        .prefix(3)
////                        .joined(separator: " ")
////                    if !notes.isEmpty {
////                        Text(notes)
////                            .lineLimit(2)
////                            .foregroundStyle(.gray)
////                    }
//                    subtitleText
//                }
//            }
//            Spacer()
////            if !entry.isCompleted {
////                HStack {
////                    if entry.isFlagged {
////                        Image(systemName: "flag.fill")
////                            .foregroundStyle(.orange)
////                    }
////                    Button {
////                        editEntry = entry
////                    } label: {
////                        Image(systemName: "info.circle")
////                    }
////                }
////            }
//        }
//        .buttonStyle(.borderless)
//        .swipeActions {
//            Button("Delete") {
//                withErrorReporting {
//                    do {
//                        _ = try database.write { db in
//                            try entry.delete(db)
//                        }
//                    }
//                }
//            }
//            .tint(.red)
////            Button(entry.isFlagged ? "Unflag" : "Flag") {
////                withErrorReporting {
////                    try database.write { db in
////                        var entry = entry
////                        entry.isFlagged.toggle()
////                        _ = try entry.saved(db)
////                    }
////                }
////            }
////            .tint(.orange)
//            Button("Details") {
//                editEntry = entry
//            }
//        }
//        .sheet(item: $editEntry) { entry in
//            NavigationStack {
//                EntryFormView(existingEntry: entry, entryCollection: entryCollection)
//            }
//        }
//    }
//
//    private func completeButtonTapped() {
//        withErrorReporting {
//            try database.write { db in
////                var entry = entry
////                entry.isCompleted.toggle()
//                _ = try entry.saved(db)
//            }
//        }
//    }
//
////    private var dueText: Text {
////        if let date = entry.date {
////            Text(date.formatted(date: .numeric, time: .shortened))
////                .foregroundStyle(isPastDue ? .red : .gray)
////        } else {
////            Text("")
////        }
////    }
//
//    private var subtitleText: Text {
//        let tagsText = tags.reduce(Text("")) { result, tag in
//            result + Text("#\(tag) ")
//                .foregroundStyle(.gray)
//                .bold()
//        }
//        return (tagsText).font(.callout)
//    }
//
//    private func title(for entry: Entry) -> some View {
//        Text(entry.spelling).font(.title3)
//    }
//}
//
//#Preview {
//    var entry: Entry!
//    var entryList: EntryCollection!
//    let _ = DB.prepareForPreviews {
//        try $0.defaultDatabase.read { db in
//            entry = try Entry.fetchOne(db)
//            entryList = try EntryCollection.fetchOne(db)!
//        }
//    }
//
//    NavigationStack {
//        List {
//            EntryRow(
//                isPastDue: false,
//                entry: entry,
//                entryCollection: entryList,
//                tags: ["point-free", "adulting"]
//            )
//        }
//    }
//}
