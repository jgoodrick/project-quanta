//
//  AppView.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI

public struct AppView: View {
    @Bindable var controller: AppController

    public init(controller: AppController) {
        self.controller = controller
    }

    public var body: some View {
        NavigationStack(path: $controller.path) {
            WordList(
                onRowTapped: {
                    controller.path.append(.detail($0))
                }
            )
            .navigationDestination(path: controller.path) { path in
                switch path {
                case .detail(let entryId):
                    WordDetail(id: entryId)
                case .newEntryForm:
                    NewEntryForm()
                }
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    AppView(controller: AppController())
        .frame(width: 500, height: 500)
}
