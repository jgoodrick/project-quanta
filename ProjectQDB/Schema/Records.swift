//
//  Records.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/24/25.
//

import Foundation
import GRDB

protocol Table: Codable, FetchableRecord, Hashable, MutablePersistableRecord {
    static var tableName: String { get }
}

extension Table {
    static var tableName: String {
        String(describing: Self.self).lowercased()
    }
    static var migrationName: String {
        "Add \(tableName) table"
    }
}

protocol Join<Left, Right>: Table {
    associatedtype Left: Entity
    associatedtype Right: Entity
}

extension Join {
    static var tableName: String {
        "\(Left.tableName)_\(Right.tableName)"
    }
}

protocol RelationalJoin<Relationship>: Join {
    associatedtype Relationship: CaseIterable & RawRepresentable<String>
}

protocol Entity: Identifiable, Table {
    var id: Int64? { get set }
}

extension Entity {
    static var reference: String { tableName + "ID" }
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
