//
//  AppView.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI

public struct AppView: View {
    @Bindable var nav: Nav

    public init(nav: Nav) {
        self.nav = nav
    }

    public var body: some View {
        NavigationStack(path: $nav.path) {
            WordList(
                onRowTapped: {
                    nav.path.append(.detail($0))
                }
            )
            .navigationDestination(path: nav.path) { path in
                switch path {
                case .detail(let entryId):
                    WordDetail(id: entryId)
                case .newEntryForm(let initialValue):
                    NewEntryForm(word: initialValue)
                }
            }
            .installQuickEntry(
                actions: .init(
                    onSubmit: { submitted in
                        nav.path.append(.newEntryForm(initialValue: submitted))
                    }
                )
            )
        }
    }
}

#Preview { let _ = DB.prepare()
    AppView(nav: Nav())
}
