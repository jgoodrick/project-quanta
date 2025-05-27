//
//  AppController.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import CasePaths
import SharingGRDB
import SwiftUI

@MainActor
@Observable
public final class AppController {
    var path: [Path] {
        didSet { bind() }
    }
    var words: WordListController {
        didSet { bind() }
    }

    @ObservationIgnored
    @Dependency(\.continuousClock) var clock
    @ObservationIgnored
    @Dependency(\.date.now) var now
    @ObservationIgnored
    @Dependency(\.uuid) var uuid

    @CasePathable
    @dynamicMemberLookup
    enum Path: Hashable {
        case detail(WordDetailController)
    }

    init(
        path: [Path] = [],
        words: WordListController = WordListController()
    ) {
        self.path = path
        self.words = words
        self.bind()
    }

    public convenience init() {
        self.init(
            path: [],
            words: WordListController()
        )
    }

    private func bind() {
        for destination in path {
            switch destination {
            case let .detail(detailModel):
                bindDetail(model: detailModel)
            }
        }
    }

    private func bindDetail(model: WordDetailController) {
//        model.onMeetingStarted = { [weak self] syncUp, attendees in
//            guard let self else { return }
//            withDependencies(from: self) {
//                path.append(.record(RecordMeetingModel(syncUp: syncUp, attendees: attendees)))
//            }
//        }
    }
}
