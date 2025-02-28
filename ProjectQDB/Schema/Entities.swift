//
//  Entities.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/24/25.
//

import Foundation

extension DB {
    struct Entry: Entity {
        var id: Int64?
        var createdAt: Date
    }

    struct Language: Entity {
        var id: Int64?
        var name: String = ""
        /// The bcp47 code that can be used to adjust the keyboard
        var keyboardID: String?
    }

    struct Spelling: Entity {
        var id: Int64?
        var text: String = ""
    }

    struct Definition: Entity {
        var id: Int64?
        var text: String
    }

    struct Usage: Entity {
        var id: Int64?
        var text: String = ""
    }

    struct Keyword: Entity {
        var id: Int64?
        var text: String
        var description: String = ""
    }

    struct Pronunciation: Entity {
        var id: Int64?
        var text: String = ""
        var audioURL: URL?
    }

    struct Image: Entity {
        var id: Int64?
        var remote: Bool
        var imageURL: URL
    }

    struct Impression: Entity {
        var id: Int64?
        var mastery: Double
        var type: String
        var datetime: Date
    }

    // MARK: With foreign keys

    struct Note: Entity {
        var id: Int64?
        var entryID: Int64
        var text: String = ""
    }

}
