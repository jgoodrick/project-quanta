//
//  WordDetail.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI
import SwiftUINavigation

struct WordDetail: View {
    let id: DB.Entry.ID

    @Dependency(\.locale) private var locale

    var body: some View {
        Load(request) { value in
            List {
                Section("Language") {
                    Text(locale.interpolatableLanguageName(of: value.language.code, capitalized: true))
                    if !value.additionalLanguages.isEmpty {
                        Text("Also used in:")
                        ForEach(value.additionalLanguages) { languageName in
                            Text(locale.interpolatableLanguageName(of: languageName.code, capitalized: true))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !value.alternativeSpellings.isEmpty {
                    Section("Alternative Spellings:") {
                        ForEach(value.alternativeSpellings) { altSpelling in
                            Text(altSpelling.text)
                        }
                    }
                }

                if !value.translations.isEmpty {
                    Section("Translations:") {
                        ForEach(value.translations) { entry in
                            TranslationCell(id: entry.id)
                        }
                    }
                }

                if !value.notes.isEmpty {
                    Section("Notes") {
                        ForEach(value.notes) { note in
                            NoteCell(id: note.id)
                        }
                    }
                }

                if !value.roots.isEmpty {
                    Section("Roots") {
                        ForEach(value.roots) { root in
                            RootCell(id: root.id)
                        }
                    }
                }
            }
            .navigationTitle("\(value.spelling.text)")
        }
    }

    var request: Request { .init(id: id) }

    struct TranslationCell: View {
        let id: DB.Entry.ID

        @State private var text = ""

        @Dependency(\.locale) private var locale

        var body: some View {
            Load(request) { loaded in
                TextField("\(locale.interpolatableLanguageName(of: loaded.language.code, capitalized: true))Translation", text: $text)
                    .task {
                        text = loaded.spelling.text
                    }
            }
        }

        var request: Request { .init(id: id) }

        struct Request: FetchKeyRequest {
            let id: DB.Entry.ID

            struct Value {
                var id: DB.Entry.ID { entry.id }
                var entry: DB.Entry
                var language: DB.Language.Name
                var spelling: DB.Entry.Spelling
            }

            func fetch(_ db: Database) throws -> Value {
                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
                guard let language = try DB.Language.Name.find(entry.language).fetchOne(db) else { throw NoMatchFound.language }
                guard let spelling = try DB.Entry.Spelling.find(entry.spelling).fetchOne(db) else { throw NoMatchFound.spelling }

                return Value(
                    entry: entry,
                    language: language,
                    spelling: spelling
                )
            }
        }
    }

    struct NoteCell: View {
        let id: DB.Entry.Note.ID

        @State private var text = ""

        var body: some View {
            Load(request) { loaded in
                TextEditor(text: $text)
                    .task {
                        text = loaded.note.text
                    }
            }
        }

        var request: Request { .init(id: id) }

        struct Request: FetchKeyRequest {
            let id: DB.Entry.Note.ID

            struct Value {
                var id: DB.Entry.Note.ID { note.id }
                var note: DB.Entry.Note
            }

            func fetch(_ db: Database) throws -> Value {
                guard let note = try DB.Entry.Note.find(id).fetchOne(db) else { throw NoMatchFound.entry }

                return Value(note: note)
            }
        }
    }

    struct RootCell: View {
        let id: DB.Entry.ID

        @State private var text = ""

        var body: some View {
            Load(request) { loaded in
                TextField("Root", text: $text)
                    .task {
                        text = loaded.spelling.text
                    }
            }
        }

        var request: Request { .init(id: id) }

        struct Request: FetchKeyRequest {
            let id: DB.Entry.ID

            struct Value {
                var id: DB.Entry.ID { entry.id }
                var entry: DB.Entry
                var language: DB.Language.Name
                var spelling: DB.Entry.Spelling
            }

            func fetch(_ db: Database) throws -> Value {
                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
                guard let language = try DB.Language.Name.find(entry.language).fetchOne(db) else { throw NoMatchFound.language }
                guard let spelling = try DB.Entry.Spelling.find(entry.spelling).fetchOne(db) else { throw NoMatchFound.spelling }

                return Value(
                    entry: entry,
                    language: language,
                    spelling: spelling
                )
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    WordDetail(id: Mock.English.Entry.hello.id)
}
