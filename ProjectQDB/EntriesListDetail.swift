////
////  EntriesListDetail.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import Sharing
//import SharingGRDB
//import SwiftUI
//
//struct EntriesListDetailView: View {
//    @State.SharedReader private var entriesState: [Entries.Record]
//    @Shared private var ordering: Ordering
//    @Shared private var showCompleted: Bool
//    private let entryCollection: EntryCollection
//
//    @State var isNewEntrySheetPresented = false
//
//    @Dependency(\.defaultDatabase) private var database
//
//    enum Ordering: String, CaseIterable {
//        case dueDate = "Due Date"
//        case priority = "Priority"
//        case title = "Title"
//        var icon: Image {
//            switch self {
//            case .dueDate:  Image(systemName: "calendar")
//            case .priority: Image(systemName: "chart.bar.fill")
//            case .title:    Image(systemName: "textformat.characters")
//            }
//        }
//        var queryString: String {
//            switch self {
//            case .dueDate:  #""date""#
//            case .priority: #""priority" DESC, "isFlagged" DESC"#
//            case .title:    #""title""#
//            }
//        }
//    }
//
//    init?(entryCollection: EntryCollection) {
//        self.entryCollection = entryCollection
//        _entriesState = State.SharedReader(value: [])
//        if let listID = entryCollection.id {
//            _ordering = Shared(wrappedValue: .dueDate, .appStorage("ordering_list_\(listID)"))
//            _showCompleted = Shared(wrappedValue: false, .appStorage("show_completed_list_\(listID)"))
//            $entriesState = SharedReader(
//                .fetch(
//                    Entries(
//                        collectionID: listID,
//                        ordering: ordering,
//                        showCompleted: showCompleted
//                    ),
//                    animation: .default
//                )
//            )
//        } else {
//            reportIssue("'list.id' required to be non-nil.")
//            return nil
//        }
//    }
//
//    var body: some View {
//        List {
//            ForEach(entriesState, id: \.entry.id) { entryState in
//                EntryRow(
//                    isPastDue: entryState.isPastDue,
//                    entry: entryState.entry,
//                    entryCollection: entryCollection,
//                    tags: entryState.tags
//                )
//            }
//        }
//        .task(id: [ordering, showCompleted] as [AnyHashable]) {
//            await withErrorReporting {
//                try await updateQuery()
//            }
//        }
//        .navigationTitle(Text(entryCollection.title))
////        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $isNewEntrySheetPresented) {
//            NavigationStack {
//                EntryFormView(entryCollection: entryCollection)
//            }
//        }
//        .toolbar {
////            ToolbarItem(placement: .bottomBar) {
//            ToolbarItem {
//                HStack {
//                    Button {
//                        isNewEntrySheetPresented = true
//                    } label: {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("New entry")
//                        }
//                        .bold()
//                        .font(.title3)
//                    }
//                    Spacer()
//                }
//            }
//            ToolbarItem(placement: .primaryAction) {
//                Menu {
//                    Menu {
//                        ForEach(Ordering.allCases, id: \.self) { ordering in
//                            Button {
//                                $ordering.withLock { $0 = ordering }
//                            } label: {
//                                Text(ordering.rawValue)
//                                ordering.icon
//                            }
//                        }
//                    } label: {
//                        Text("Sort By")
//                        Text(ordering.rawValue)
//                        Image(systemName: "arrow.up.arrow.down")
//                    }
//                    Button {
//                        $showCompleted.withLock { $0.toggle() }
//                    } label: {
//                        Text(showCompleted ? "Hide Completed" : "Show Completed")
//                        Image(systemName: showCompleted ? "eye.slash.fill" : "eye")
//                    }
//                } label: {
//                    Image(systemName: "ellipsis.circle")
//                }
//            }
//        }
//    }
//
//    private func updateQuery() async throws {
//        guard let listID = entryCollection.id
//        else { return }
//
//        try await $entriesState.load(
//            .fetch(
//                Entries(collectionID: listID, ordering: ordering, showCompleted: showCompleted),
//                animation: .default
//            )
//        )
//    }
//
//    private struct Entries: FetchKeyRequest {
//        let collectionID: Int64
//        let ordering: Ordering
//        let showCompleted: Bool
//        func fetch(_ db: Database) throws -> [Record] {
//            try Record.fetchAll(
//                db,
//                sql: """
//                SELECT 
//                  "entries".*, 
//                  group_concat("tags"."title", ',') AS "commaSeparatedTags",
//                  NOT "isCompleted" AND coalesce("entries"."date", date('now')) < date('now') as "isPastDue"
//                FROM "entries"
//                LEFT JOIN "entriesTags" ON "entries"."id" = "entriesTags"."entryID"
//                LEFT JOIN "tags" ON "entriesTags"."tagID" = "tags"."id"
//                WHERE 
//                  "entries"."listID" = ?
//                  \(showCompleted ? "" : #"AND NOT "isCompleted""#)
//                GROUP BY "entries"."id"
//                ORDER BY
//                  "entries"."isCompleted" ASC, 
//                  \(ordering.queryString)
//                """,
//                arguments: [collectionID]
//            )
//        }
//        struct Record: Decodable, FetchableRecord {
//            var entry: Entry
//            var isPastDue: Bool
//            var commaSeparatedTags: String?
//            var tags: [String] {
//                (commaSeparatedTags ?? "").split(separator: ",").map(String.init)
//            }
//        }
//    }
//}
//
//#Preview {
//    let entryCollection = try! prepareDependencies {
//        $0.defaultDatabase = try ProjectQDB.appDatabase()
//        return try $0.defaultDatabase.read { db in
//            try EntryCollection.fetchOne(db)!
//        }
//    }
//    NavigationStack {
//        EntriesListDetailView(entryCollection: entryCollection)
//    }
//}
