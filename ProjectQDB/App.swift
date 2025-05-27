//
//  App.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/16/25.
//

import QDBCore
import SharingGRDB
import SwiftUI

@main
struct ProjectQDBApp: App {
    static let controller = AppController()

    init() {
        if !isTesting {
            try! prepareDependencies {
                $0.defaultDatabase = try QDBCore.appDatabase()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if !isTesting {
                AppView(controller: Self.controller)
            }
        }
    }
}
