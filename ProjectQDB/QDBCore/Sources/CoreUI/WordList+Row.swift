//
//  WordList+Row.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI
import UIComponents

extension WordList {
    struct Row: View {
        let model: Model
        
        struct Model: Identifiable {
            let id: UUID
            let spelling: String
            let translations: [String]
        }

        var body: some View {
//            VStack(alignment: .leading) {
//                Text(model.spelling)
//                    .font(.headline)
//
//                Spacer(minLength: 0)
//
//                HStack {
//                    ForEach(model.translations.enumerated(), id: \.0) { (index, translation) in
//                        Text(translation)
//                    }
//                }
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .contentShape(Rectangle())
        }
    }
//
//        var request: Request { .init(id: id) }
//
//        struct Request: FetchKeyRequest {
//            let id: DB.Entry.ID
//            struct Value {
//                var entry: DB.Entry
//                var synonyms: [DB.Entry]
//            }
//            enum NoMatchFound: Error {
//                case entry
//            }
//            func fetch(_ db: Database) throws -> Value {
//                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
//                return Value(
//                    entry: entry,
//                    synonyms: try DB.Semantic.Synonym
//                        .where { $0.base.eq(id) }
//                        .join(DB.Entry.all) { $0.synonym.eq($1.id) }
//                        .select { _, entry in entry }
//                        .fetchAll(db)
//                )
//        }
//    }
}

#Preview {
    WordList.Row(
        model: .init(
            id: .init(),
            spelling: "example",
            translations: ["exemplo", "esempio"]
        )
    )
}
