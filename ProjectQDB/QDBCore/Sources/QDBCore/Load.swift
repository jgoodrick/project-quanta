//
//  Load.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SharingGRDB
import SwiftUI

struct Load<Value, Loaded: View>: View {
    init(
        _ request: some FetchKeyRequest<Value>,
        messageOnError: String? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        @ViewBuilder load: @escaping (Value) throws -> Loaded
    ) {
        self.request = request
        self.messageOnError = messageOnError
        self.fileID = fileID
        self.filePath = filePath
        self.line = line
        self.column = column
        self.load = load
    }

    let request: any FetchKeyRequest<Value>
    var messageOnError: String? = nil
    var fileID: StaticString
    var filePath: StaticString
    var line: UInt
    var column: UInt
    let load: (Value) throws -> Loaded

    @Dependency(\.defaultDatabase) private var db

    var body: some View {
        withErrorReporting(
            messageOnError,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        ) {
            try db.read { db in
                let value = try request.fetch(db)
                return try load(value)
            }
        }
    }
}

