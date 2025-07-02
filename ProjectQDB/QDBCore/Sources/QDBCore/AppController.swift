//
//  AppController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import CasePaths
import SharingGRDB
import SwiftUI

@MainActor
@Observable
public final class AppController {
    var path: [Path] = []

    @CasePathable @dynamicMemberLookup
    enum Path: Hashable {
        case detail(DB.Entry.ID)
        case newEntryForm
    }

    public init() {}
}
