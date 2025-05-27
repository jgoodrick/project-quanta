////
////  EntryCollections.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import Dependencies
//import GRDB
//import Sharing
//import SharingGRDB
//import SwiftUI
//
//struct EntryCollections: View {
//    @SharedReader(.fetch(AllEntries(), animation: .default))
//    private var allEntries: [AllEntries.Record]
////    @SharedReader(.fetch(Stats())) private var stats = Stats.Value()
//
//    private let stats = Stats.Value()
//    @State private var isAddListPresented = false
//    @State private var searchText = ""
//    @State private var addEntryText = ""
//
//    @Dependency(\.defaultDatabase) private var database
//
//    var body: some View {
//        List {
//            TextField("Add", text: $addEntryText)
//                .onSubmit {
//                    var entry: DB.Entry?
//                    var spelling: DB.Spelling?
//                    try? database.write { db in
//                        try db.execute(sql: "PRAGMA foreign_keys = ON;")
//                        try db.execute(sql: "PRAGMA foreign_key_check;")
//
//                        entry = DB.Entry(createdAt: .now)
//                        spelling = DB.Spelling(text: addEntryText)
//
//                        try entry?.insert(db)
//                        try spelling?.insert(db)
//
//                        guard let entryID = entry?.id, let spellingID = spelling?.id else {
//                            reportIssue("Could not read ids after saving")
//                            return
//                        }
//
//                        print("Entry ID: \(entryID), Spelling ID: \(spellingID)")
//
//                        do {
//                            var entrySpelling = DB.EntrySpelling(entryID: entryID, spellingID: spellingID)
//                            try entrySpelling.insert(db)
//                            print("Successfully inserted entry_spelling")
//                        } catch {
//                            reportIssue("Failed to insert entry_spelling: \(error)")
//                        }
//                        print("Successfully inserted entry_spelling")
//                    }
//                }
//
//            if searchText.isEmpty {
//                Section {
//                    Grid(horizontalSpacing: 16, verticalSpacing: 16) {
//                        GridRow {
//                            EntryGridCell(
//                                color: .blue,
//                                count: stats.todayCount,
//                                iconName: "calendar.circle.fill",
//                                title: "Today"
//                            ) {}
//                            EntryGridCell(
//                                color: .red,
//                                count: stats.scheduledCount,
//                                iconName: "calendar.circle.fill",
//                                title: "Scheduled"
//                            ) {}
//                        }
//                        GridRow {
//                            EntryGridCell(
//                                color: .gray,
//                                count: stats.allCount,
//                                iconName: "tray.circle.fill",
//                                title: "All"
//                            ) {}
//                            EntryGridCell(
//                                color: .orange,
//                                count: stats.flaggedCount,
//                                iconName: "flag.circle.fill",
//                                title: "Flagged"
//                            ) {}
//                        }
//                        GridRow {
//                            EntryGridCell(
//                                color: .gray,
//                                count: stats.completedCount,
//                                iconName: "checkmark.circle.fill",
//                                title: "Completed"
//                            ) {}
//                        }
//                    }
//                }
//                .buttonStyle(.plain)
//
//                Section {
//                    ForEach(allEntries) { entry in
//                        NavigationLink {
//                            Text(entry.spelling ?? "(no spelling)")
////                            EntriesListDetailView(entryCollection: state.entryCollection)
//                        } label: {
//                            Text(entry.spelling ?? "(no spelling)")
////                            EntriesListRow(
////                                entryCount: state.entryCount,
////                                entryCollection: state.entryCollection
////                            )
//                        }
//                    }
//                } header: {
//                    Text("My lists")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundStyle(.black)
//                }
//            } else {
////                SearchEntriesView(searchText: searchText)
//            }
//        }
//        // NB: This explicit view identity works around a bug with 'List' view state not getting reset.
//        .id(searchText)
//        .listStyle(.plain)
//        .toolbar {
//            Button("Add list") {
//                isAddListPresented = true
//            }
//        }
////        .sheet(isPresented: $isAddListPresented) {
////            NavigationStack {
////                EntriesListForm()
////                    .navigationTitle("New list")
////            }
////            .presentationDetents([.medium])
////        }
////        .sheet(isPresented: $isAddListPresented) {
////            NavigationStack {
////                EntriesListForm()
////                    .navigationTitle("New list")
////            }
////            .presentationDetents([.medium])
////        }
//        .searchable(text: $searchText)
//    }
//
//    private struct AllEntries: FetchKeyRequest {
//        func fetch(_ db: Database) throws -> [Record] {
//            try Record.fetchAll(
//                db,
//                sql: """
//                SELECT 
//                    e.id AS entry_id,
//                    s.text AS spelling
//                FROM entry e
//                    LEFT JOIN entry_spelling es ON e.id = es.entryID
//                    LEFT JOIN spelling s ON es.spellingID = s.id
//                ORDER BY e.id;
//                """
//            )
//        }
//        struct Record: Decodable, FetchableRecord, Identifiable {
//            var id: String { "\(entry_id) spelling)" }
//            var entry_id: Int64
//            var spelling: String?
//        }
//    }
//    private struct Stats {
////    private struct Stats: FetchKeyRequest {
////        func fetch(_ db: Database) throws -> Value {
////            let todayCount = try Int.fetchOne(db, sql: """
////        SELECT count(*)
////        FROM "entries"
////        WHERE date("date") = date('now')
////        """) ?? 0
////            let allCount = try Entry.fetchCount(db)
////            let scheduledCount = try Int.fetchOne(db, sql: """
////        SELECT count(*)
////        FROM "entries"
////        WHERE date("date") > date('now')
////        """) ?? 0
////            let flaggedCount = try Entry.filter(Column("isFlagged")).fetchCount(db)
////            let completedCount = try Entry.filter(Column("isCompleted")).fetchCount(db)
////            return Value(
////                allCount: allCount,
////                completedCount: completedCount,
////                flaggedCount: flaggedCount,
////                scheduledCount: scheduledCount,
////                todayCount: todayCount
////            )
////        }
//        struct Value {
//            var allCount = 0
//            var completedCount = 0
//            var flaggedCount = 0
//            var scheduledCount = 0
//            var todayCount = 0
//        }
//    }
//}
//
//private struct EntryGridCell: View {
//    let color: Color
//    let count: Int
//    let iconName: String
//    let title: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(alignment: .top) {
//                VStack(alignment: .leading) {
//                    Image(systemName: iconName)
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundStyle(color)
//                    Text(title)
//                        .bold()
//                }
//                Spacer()
//                Text("\(count)")
//                    .font(.largeTitle)
//                    .fontDesign(.rounded)
//                    .bold()
//            }
//            .padding()
//            .background(.black.opacity(0.05))
//            .cornerRadius(10)
//        }
//    }
//}
//
//#Preview {
//    let _ = try! prepareDependencies {
//        $0.defaultDatabase = try DB.appDatabase()
//    }
//    NavigationStack {
//        EntryCollections()
//    }
//}
