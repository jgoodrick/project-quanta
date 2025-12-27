//
//  AppView.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import CoreDB
import SQLiteData
import SwiftUI

public struct AppView: View {
    @Dependency(\.defaultDatabase) private var database

    public var body: some View {
        Text("App View")
//        NavigationStack(path: $nav.path) {
//            WordList(
//                onRowTapped: {
//                    nav.path.append(.detail($0))
//                }
//            )
//            .navigationDestination(path: nav.path) { path in
//                switch path {
//                case .detail(let entryId):
//                    WordDetail(id: entryId)
//                case .newEntryForm:
//                    NewEntryForm()
//                }
//            }
//            .installQuickEntry(
//                actions: .init(
//                    onSubmit: { submitted in
//                        if let match = CoreDB.Entry.Match.firstMatch(for: submitted) {
//                            nav.path.append(.detail(match))
//                        } else {
//                            nav.path.append(.newEntryForm)
//                        }
//                    }
//                )
//            )
//            .toolbar {
//                ToolbarItem {
//                    Button("Seed") {
//                        withErrorReporting {
//                            try database.write { db in
//                                try db.seedSampleData()
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

//#Preview { let _ = CoreDB.prepare()
//    AppView(nav: Nav())
//}
