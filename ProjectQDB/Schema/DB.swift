//
//  Schema.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/22/25.
//

import Foundation
import GRDB
import IssueReporting
import SharingGRDB

enum DB {}

extension DB {

    // The context-aware database used by the app and previews
    static func shared() throws -> any DatabaseWriter {

        let database: any DatabaseWriter = try loadWriter()

//        try makeMigrator().migrate(database)

        return database
    }

    fileprivate static func loadWriter() throws -> any DatabaseWriter {
        var configuration = Configuration()

        // prints db info for debugging
        #if DEBUG
        configuration.prepareDatabase { db in
            db.trace(options: .profile) {
                print($0.expandedDescription)
            }
        }
        #endif

        @Dependency(\.context) var context

        switch context {
        case .live:
            let path = URL.documentsDirectory
                .appending(component: "db.sqlite")
                .path()

            print("open", path)

            return try DatabasePool(
                path: path,
                configuration: configuration
            )
        default:
            return try DatabaseQueue(
                configuration: configuration
            )
        }
    }

    static func prepareForPreviews() {
        prepareForPreviews { _ in }
    }

    static func prepareForPreviews<R>(
        _ updateValues: (inout DependencyValues) throws -> R
    ) -> R {
        try! prepareDependencies {
            $0.defaultDatabase = try DB.shared()
            return try updateValues(&$0)
        }
    }
}

