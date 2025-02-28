//
//  AppDatabase+Mocks.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/24/25.
//

import GRDB

#if DEBUG
extension Database {
    func createMockData() throws {
        //        try createDebugEntriesLists()
        //        try createDebugEntries()
        //        try createDebugTags()
    }

    func createDebugEntriesLists() throws {
        //        _ = try EntryCollection(title: "Personal").inserted(self)
        //        _ = try EntryCollection(title: "Family").inserted(self)
        //        _ = try EntryCollection(title: "Business").inserted(self)
    }

    func createDebugEntries() throws {
        //        _ = try Entry(
        //            spelling: "Groceries"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Haircut"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Doctor appointment"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Take a walk"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Buy concert tickets"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Pick up kids from school"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Get laundry"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Take out trash"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Call accountant"
        //        )
        //        .inserted(self)
        //        _ = try Entry(
        //            spelling: "Send weekly emails"
        //        )
        //        .inserted(self)
    }

    func createDebugTags() throws {
        //        _ = try Tag(title: "car").inserted(self)
        //        _ = try Tag(title: "kids").inserted(self)
        //        _ = try Tag(title: "someday").inserted(self)
        //        _ = try Tag(title: "optional").inserted(self)
        //        _ = try Tag(title: "social").inserted(self)
        //        _ = try Tag(title: "night").inserted(self)
        //        _ = try Tag(title: "adulting").inserted(self)
        //        _ = try Entry_Tag(entryID: 1, tagID: 3).inserted(self)
        //        _ = try Entry_Tag(entryID: 1, tagID: 4).inserted(self)
        //        _ = try Entry_Tag(entryID: 1, tagID: 7).inserted(self)
        //        _ = try Entry_Tag(entryID: 2, tagID: 3).inserted(self)
        //        _ = try Entry_Tag(entryID: 2, tagID: 4).inserted(self)
        //        _ = try Entry_Tag(entryID: 3, tagID: 7).inserted(self)
        //        _ = try Entry_Tag(entryID: 4, tagID: 1).inserted(self)
        //        _ = try Entry_Tag(entryID: 4, tagID: 2).inserted(self)
    }
}
#endif
