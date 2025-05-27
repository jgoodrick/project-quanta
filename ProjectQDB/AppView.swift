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
            WordList(controller: controller.words)
                .navigationDestination(for: AppController.Path.self) { path in
                    switch path {
                    case let .detail(controller):
                        WordDetail(controller: controller)
                    }
                }
        }
    }
}

#Preview {
    let _ = DB.prepare()
    AppView(controller: AppController())
}
