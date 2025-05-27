////
////  SearchEntries.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/22/25.
////
//
//import IssueReporting
//import SharingGRDB
//import SwiftUI
//
//struct SearchEntriesView: View {
//    @State.SharedReader(value: SearchEntries.Value()) var searchEntries
//
//    let searchText: String
//    @State var showCompletedInSearchResults = false
//
//    @Dependency(\.defaultDatabase) private var database
//
//    init(searchText: String) {
//        self.searchText = searchText
////        $searchEntries = SharedReader(
////            wrappedValue: searchEntries,
////            .fetch(
////                SearchEntries(
////                    showCompletedInSearchResults: showCompletedInSearchResults,
////                    searchText: searchText
////                ),
////                animation: .default
////            )
////        )
//    }
//
//    var body: some View {
//        HStack {
////            Text("\(searchEntries.completedCount) Completed")
////                .monospacedDigit()
////                .contentTransition(.numericText())
////            if searchEntries.completedCount > 0 {
////                Text("•")
////                Menu {
////                    Text("Clear Completed Entries")
////                    Button("Older Than 1 Month") { deleteCompletedEntries(monthsAgo: 1) }
////                    Button("Older Than 6 Months") { deleteCompletedEntries(monthsAgo: 6) }
////                    Button("Older Than 1 year") { deleteCompletedEntries(monthsAgo: 12) }
////                    Button("All Completed") { deleteCompletedEntries() }
////                } label: {
////                    Text("Clear")
////                }
////                Spacer()
////                if showCompletedInSearchResults {
////                    Button("Hide") {
////                        showCompletedInSearchResults = false
////                    }
////                } else {
////                    Button("Show") {
////                        showCompletedInSearchResults = true
////                    }
////                }
////            }
//        }
//        .buttonStyle(.borderless)
//        .task(id: [searchText, showCompletedInSearchResults] as [AnyHashable]) {
//            await withErrorReporting {
//                try await updateSearchQuery()
//            }
//        }
//
////        ForEach(searchEntries.entries, id: \.entry.id) { entry in
////            EntryRow(
////                isPastDue: entry.isPastDue,
////                entry: entry.entry,
////                entriesList: entry.entriesList,
////                tags: (entry.commaSeparatedTags ?? "").split(separator: ",").map(String.init)
////            )
////        }
//    }
//
//    private func updateSearchQuery() async throws {
////        if searchText.isEmpty {
////            showCompletedInSearchResults = false
////        }
////        try await $searchEntries.load(
////            .fetch(
////                SearchEntries(
////                    showCompletedInSearchResults: showCompletedInSearchResults,
////                    searchText: searchText
////                ),
////                animation: .default
////            )
////        )
//    }
//
//    private func deleteCompletedEntries(monthsAgo: Int? = nil) {
//        withErrorReporting {
//            try database.write { db in
//                let baseQuery = searchQueryBase(searchText: searchText)
//                    .filter(Column("isCompleted"))
//                if let monthsAgo {
//                    _ = try baseQuery
//                        .filter(Column("date") < "date('now', '-\(monthsAgo) months')")
//                        .deleteAll(db)
//                } else {
//                    _ = try baseQuery.deleteAll(db)
//                }
//            }
//        }
//    }
//
//    struct SearchEntries: FetchKeyRequest {
////        let showCompletedInSearchResults: Bool
////        let searchText: String
////
//        func fetch(_ db: Database) throws -> Value {
////            struct LocalRequest: Decodable, FetchableRecord {
////                var isPastDue: Bool
////                let entry: Entry
////                let entriesListID: Int64
////                let commaSeparatedTags: String?
////            }
////            let entries = try LocalRequest.fetchAll(
////                db,
////                SQLRequest(literal: """
////          SELECT 
////            "entries".*,
////            "entryCollection"."id" AS "entriesListID",
////            group_concat("tags"."name", ',') AS "commaSeparatedTags",
////            NOT "isCompleted" AND coalesce("entries"."date", date('now')) < date('now') AS "isPastDue"
////          FROM "entries"
////          LEFT JOIN "entryCollection" ON "entries"."listID" = "entryCollection"."id"
////          LEFT JOIN "entriesTags" ON "entries"."id" = "entriesTags"."entryID"
////          LEFT JOIN "tags" ON "entriesTags"."tagID" = "tags"."id"
////          WHERE 
////            (
////              "entries"."title" COLLATE NOCASE LIKE \("%\(searchText)%")
////                OR "entries"."notes" COLLATE NOCASE LIKE \("%\(searchText)%")
////            )
////            \(sql: showCompletedInSearchResults ? "" : #"AND NOT "entries"."isCompleted""#)
////          GROUP BY "entries"."id"
////          ORDER BY
////            "entries"."isCompleted", "entries"."date" 
////          """)
////            )
////
////            // NB: We are loading lists as a separate query because we are not sure how to join
////            //     "entryCollection" into the above query and decode it into 'State'. Ideally this
////            //     could all be done with a single query.
////            let entryCollection = try EntryCollection.fetchAll(
////                db,
////                keys: Set(entries.map(\.entriesListID))
////            )
////
////            let completedCount = try searchQueryBase(searchText: searchText)
////                .filter(Column("isCompleted"))
////                .fetchCount(db)
////
//            return Value(
////                completedCount: completedCount,
////                entries: entries.map { entry in
////                    Value.Entry(
////                        isPastDue: entry.isPastDue,
////                        entry: entry.entry,
////                        entriesList: entryCollection.first(where: { $0.id == entry.entry.listID} )!,
////                        commaSeparatedTags: entry.commaSeparatedTags
////                    )
////                }
//            )
//        }
//        struct Value {
////            var completedCount = 0
////            var entries: [Entry] = []
//            struct Entry: Decodable, FetchableRecord {
////                var isPastDue: Bool
////                let entry: ProjectQDB.Entry
////                let entriesList: EntryCollection
////                let commaSeparatedTags: String?
//            }
//        }
//    }
//}
//
//private func searchQueryBase(searchText: String) -> QueryInterfaceRequest<Entry> {
//    Entry
//        .filter(
//            Column("title").collating(.nocase).like("%\(searchText.lowercased())%")
//            || Column("notes").collating(.nocase).like("%\(searchText.lowercased())%")
//        )
//}
//
//#Preview {
//    @Previewable @State var searchText = "take"
//    let _ = try! prepareDependencies {
//        $0.defaultDatabase = try ProjectQDB.appDatabase()
//    }
//
//    NavigationStack {
//        List {
//            if !searchText.isEmpty {
//                SearchEntriesView(searchText: searchText)
//            } else {
//                Text(#"Tap "Search"..."#)
//            }
//        }
//        .searchable(text: $searchText)
//    }
//}
