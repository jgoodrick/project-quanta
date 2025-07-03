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
                    spelling: value.spelling.text,
                    translations: value.synonyms.map(\.spelling.text)
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
                var spelling: DB.Entry.Spelling
                var language: DB.Language.Name
                var synonyms: [Synonym]

                struct Synonym {
                    let entry: DB.Entry.ID
                    let spelling: DB.Entry.Spelling
                }
            }
            enum NoMatchFound: Error {
                case entry
                case spelling
                case language
            }
            func fetch(_ db: Database) throws -> Value {
                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
                guard let spelling = try DB.Entry.Spelling.find(entry.spelling).fetchOne(db) else { throw NoMatchFound.spelling }
                guard let language = try DB.Language.Name.find(entry.language).fetchOne(db) else { throw NoMatchFound.language }
                let synonyms = try DB.Semantic.Synonym.where({ $0.synonym.eq(id) }).fetchAll(db).compactMap { (syn) -> Value.Synonym? in
                    guard let spelling = try DB.Entry.Spelling.find(syn.base).fetchOne(db) else { return nil }
                    return Value.Synonym(
                        entry: syn.base,
                        spelling: spelling
                    )
                }
                return Value(
                    entry: entry,
                    spelling: spelling,
                    language: language,
                    synonyms: synonyms
                )
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    WordList.Row(id: Mock.English.Entry.hello.id)
}
