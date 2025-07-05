//
//  WordList+Row.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SharingGRDB
import SwiftUI

extension WordList {
    struct Row: View {
        let id: DB.Entry.ID

        var body: some View {
            Load(request) { value in
                Content(
                    spelling: value.entry.spelling,
                    translations: value.synonyms.map(\.spelling)
                )
            }
        }

        struct Content: View {
            let spelling: String
            let translations: [String]

            var body: some View {
                VStack(alignment: .leading) {
                    Text(spelling)
                        .font(.headline)

                    Spacer(minLength: 0)

                    HStack {
                        ForEach(translations.enumerated().map(\.self), id: \.0) { (index, translation) in
                            Text(translation)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .contentShape(Rectangle())
            }
        }

        var request: Request { .init(id: id) }

        struct Request: FetchKeyRequest {
            let id: DB.Entry.ID
            struct Value {
                var entry: DB.Entry
                var synonyms: [DB.Entry]
            }
            enum NoMatchFound: Error {
                case entry
            }
            func fetch(_ db: Database) throws -> Value {
                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
                return Value(
                    entry: entry,
                    synonyms: try DB.Semantic.Synonym
                        .where { $0.base.eq(id) }
                        .join(DB.Entry.all) { $0.synonym.eq($1.id) }
                        .select { _, entry in entry }
                        .fetchAll(db)
                )
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    WordList.Row(id: Mock.English.Entry.hello.id)
}
