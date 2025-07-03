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
    @Dependency(\.context) var context
    static let nav = Nav()

    init() {
        if context == .live {
            prepareDependencies {
                $0.defaultDatabase = try! QDBCore.appDatabase()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if context == .live {
                AppView(nav: Self.nav)
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    AppView(nav: Nav())
}
