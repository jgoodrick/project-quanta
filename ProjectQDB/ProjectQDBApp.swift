//
//  ProjectQDBApp.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/16/25.
//

import Dependencies
import GRDB
import SwiftUI

@main
struct RemindersApp: App {
    init() {
        try! prepareDependencies {
            $0.defaultDatabase = try DB.appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                EntryCollections()
            }
        }
    }
}
