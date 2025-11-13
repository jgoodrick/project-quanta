//
//  Schema+Migration.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import Dependencies
import GRDB
import SQLiteData
import StructuredQueriesGRDB

extension DB {
    public static func prepare() {
        try! prepareDependencies {
            $0.defaultDatabase = try QDBCore.appDatabase()
        }
    }

    static func createInitialTables(db: Database) throws {
        try Entry.migrate(db: db)
        try Noun.migrate(db: db)
        try Etymology.migrate(db: db)
        try Verb.migrate(db: db)
        try Semantic.migrate(db: db)
        try Phonetic.migrate(db: db)
        try Orthographic.migrate(db: db)
    }
}

extension DB.Entry {
    static func migrate(db: Database) throws {
        try migrateWithoutForeignKeys(db: db)
        try migrateWithForeignKeys(db: db)
        try Joins.migrate(db: db)
    }

    static func migrateWithoutForeignKeys(db: Database) throws {
        try createTablesWithoutForeignKeys(db: db)
        try createIndicesWithoutForeignKeys(db: db)
    }

    static func createTablesWithoutForeignKeys(db: Database) throws {
        try db.execute(sql:
          """
          CREATE TABLE \(Definition.tableName) (
            "\(Definition.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Definition.columns.text.name)" TEXT NOT NULL
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Usage.tableName) (
            "\(Usage.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Usage.columns.text.name)" TEXT NOT NULL
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Keyword.tableName) (
            "\(Keyword.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Keyword.columns.text.name)" TEXT NOT NULL UNIQUE COLLATE NOCASE,
            "\(Keyword.columns.description.name)" TEXT NOT NULL
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Pronunciation.tableName) (
            "\(Pronunciation.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Pronunciation.columns.text.name)" TEXT NOT NULL,
            "\(Pronunciation.columns.audioURL.name)" TEXT
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Image.tableName) (
            "\(Image.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Image.columns.imageURL.name)" TEXT NOT NULL,
            "\(Image.columns.remote.name)" BOOLEAN
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Impression.tableName) (
            "\(Impression.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Impression.columns.mastery.name)" FLOAT NOT NULL,
            "\(Impression.columns.mode.name)" TEXT NOT NULL,
            "\(Impression.columns.recorded.name)" TEXT NOT NULL
          )
          """
        )
    }

    static func createIndicesWithoutForeignKeys(db: Database) throws {
        try db.createIndex(Keyword.self, on: \.text)
        try db.createIndex(Impression.self, on: \.mode)
    }

    static func migrateWithForeignKeys(db: Database) throws {
        try db.execute(sql:
          """
          CREATE TABLE \(DB.Entry.tableName) (
            "\(DB.Entry.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(DB.Entry.columns.spelling.name)" INTEGER NOT NULL,
            "\(DB.Entry.columns.language.name)" TEXT NOT NULL,
            "\(DB.Entry.columns.recorded.name)" TEXT NOT NULL
          )
          """
        )
        try db.execute(sql:
          """
          CREATE TABLE \(Note.tableName) (
            "\(Note.columns.id.name)" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            "\(Note.columns.entry.name)" INTEGER,
            "\(Note.columns.text.name)" TEXT NOT NULL,
            "\(Note.columns.recorded.name)" TEXT NOT NULL,
            FOREIGN KEY("\(Note.columns.entry.name)") REFERENCES \(DB.Entry.tableName)("id") ON DELETE CASCADE
          )
          """
        )

        try db.createIndex(Note.self, on: \.entry)
    }
}

extension DB.Entry.Joins {
    static func migrate(db: Database) throws {
        try db.createEntryJoinTable(
            EntryAdditionalSpelling.self,
            DB.Entry.self,
            of: \.entry,
            to: \.additionalSpelling,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryDefinition.self,
            DB.Entry.Definition.self,
            of: \.entry,
            to: \.definition,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryUsage.self,
            DB.Entry.Usage.self,
            of: \.entry,
            to: \.usage,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryKeyword.self,
            DB.Entry.Keyword.self,
            of: \.entry,
            to: \.keyword,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryPronunciation.self,
            DB.Entry.Pronunciation.self,
            of: \.entry,
            to: \.pronunciation,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryImage.self,
            DB.Entry.Image.self,
            of: \.entry,
            to: \.image,
            id: \.id
        )
        try db.createEntryJoinTable(
            EntryImpression.self,
            DB.Entry.Impression.self,
            of: \.entry,
            to: \.impression,
            id: \.id
        )
    }
}

extension DB.Noun {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Number.Singular.self,
            of: \.base,
            to: \.singular
        )
        try db.createEntryEntryJoinTable(
            Number.Plural.self,
            of: \.base,
            to: \.plural
        )
        try db.createEntryEntryJoinTable(
            Gender.Masculine.self,
            of: \.base,
            to: \.masculine
        )
        try db.createEntryEntryJoinTable(
            Gender.Feminine.self,
            of: \.base,
            to: \.feminine
        )
        try db.createEntryEntryJoinTable(
            Gender.Neuter.self,
            of: \.base,
            to: \.neuter
        )
        try db.createEntryEntryJoinTable(
            Case.Nominative.self,
            of: \.base,
            to: \.nominative
        )
        try db.createEntryEntryJoinTable(
            Case.Objective.self,
            of: \.base,
            to: \.objective
        )
        try db.createEntryEntryJoinTable(
            Case.Possessive.self,
            of: \.base,
            to: \.possessive
        )
        try db.createEntryEntryJoinTable(
            Case.Vocative.self,
            of: \.base,
            to: \.vocative
        )
        try db.createEntryEntryJoinTable(
            Case.Dative.self,
            of: \.base,
            to: \.dative
        )
        try db.createEntryEntryJoinTable(
            Case.Ablative.self,
            of: \.base,
            to: \.ablative
        )
        try db.createEntryEntryJoinTable(
            Case.Instrumental.self,
            of: \.base,
            to: \.instrumental
        )
        try db.createEntryEntryJoinTable(
            Case.Locative.self,
            of: \.base,
            to: \.locative
        )
        try db.createEntryEntryJoinTable(
            Size.Diminutive.self,
            of: \.base,
            to: \.diminished
        )
        try db.createEntryEntryJoinTable(
            Size.Augmentative.self,
            of: \.base,
            to: \.augmented
        )
    }
}

extension DB.Etymology {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Derivation.self,
            of: \.base,
            to: \.derived
        )
        try db.createEntryEntryJoinTable(
            Cognate.self,
            of: \.base,
            to: \.cognate
        )
        try db.createEntryEntryJoinTable(
            Root.self,
            of: \.base,
            to: \.root
        )
    }
}

extension DB.Verb {
    static func migrate(db: Database) throws {
        try Person.migrate(db: db)
        try Gender.migrate(db: db)
        try Number.migrate(db: db)
        try Tense.migrate(db: db)
        try Aspect.migrate(db: db)
        try Mood.migrate(db: db)
        try Voice.migrate(db: db)
    }
}

extension DB.Verb.Person {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            First.self,
            of: \.base,
            to: \.firstPerson
        )
        try db.createEntryEntryJoinTable(
            Second.self,
            of: \.base,
            to: \.secondPerson
        )
        try db.createEntryEntryJoinTable(
            Third.self,
            of: \.base,
            to: \.thirdPerson
        )
    }
}

extension DB.Verb.Gender {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Unknown.self,
            of: \.base,
            to: \.unknown
        )
        try db.createEntryEntryJoinTable(
            Masculine.self,
            of: \.base,
            to: \.masculine
        )
        try db.createEntryEntryJoinTable(
            Feminine.self,
            of: \.base,
            to: \.feminine
        )
        try db.createEntryEntryJoinTable(
            Neuter.self,
            of: \.base,
            to: \.neuter
        )
    }
}

extension DB.Verb.Number {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Singular.self,
            of: \.base,
            to: \.singular
        )
        try db.createEntryEntryJoinTable(
            Plural.self,
            of: \.base,
            to: \.plural
        )
    }
}

extension DB.Verb.Tense {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Present.self,
            of: \.base,
            to: \.present
        )
        try db.createEntryEntryJoinTable(
            Past.self,
            of: \.base,
            to: \.past
        )
        try db.createEntryEntryJoinTable(
            Future.self,
            of: \.base,
            to: \.future
        )
    }
}

extension DB.Verb.Aspect {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Simple.self,
            of: \.base,
            to: \.simple
        )
        try db.createEntryEntryJoinTable(
            Continuous.self,
            of: \.base,
            to: \.continuous
        )
        try db.createEntryEntryJoinTable(
            Perfect.self,
            of: \.base,
            to: \.perfect
        )
    }
}

extension DB.Verb.Mood {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Indicative.self,
            of: \.base,
            to: \.indicative
        )
        try db.createEntryEntryJoinTable(
            Imperative.self,
            of: \.base,
            to: \.imperative
        )
        try db.createEntryEntryJoinTable(
            Subjunctive.self,
            of: \.base,
            to: \.subjunctive
        )
    }
}

extension DB.Verb.Voice {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Active.self,
            of: \.base,
            to: \.active
        )
        try db.createEntryEntryJoinTable(
            Passive.self,
            of: \.base,
            to: \.passive
        )
    }
}

extension DB.Semantic {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Synonym.self,
            of: \.base,
            to: \.synonym
        )
        try db.createEntryEntryJoinTable(
            Antonym.self,
            of: \.base,
            to: \.antonym
        )
        try db.createEntryEntryJoinTable(
            Hypernym.self,
            of: \.base,
            to: \.hypernym
        )
        try db.createEntryEntryJoinTable(
            Hyponym.self,
            of: \.base,
            to: \.hyponym
        )
        try db.createEntryEntryJoinTable(
            Meronym.self,
            of: \.base,
            to: \.meronym
        )
        try db.createEntryEntryJoinTable(
            Holonym.self,
            of: \.base,
            to: \.holonym
        )
        try db.createEntryEntryJoinTable(
            Troponym.self,
            of: \.base,
            to: \.troponym
        )
        try db.createEntryEntryJoinTable(
            Formal.self,
            of: \.base,
            to: \.formal
        )
        try db.createEntryEntryJoinTable(
            Informal.self,
            of: \.base,
            to: \.informal
        )
        try db.createEntryEntryJoinTable(
            Slang.self,
            of: \.base,
            to: \.slang
        )
    }
}

extension DB.Phonetic {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            Homophone.self,
            of: \.base,
            to: \.homophone
        )
        try db.createEntryEntryJoinTable(
            Homograph.self,
            of: \.base,
            to: \.homograph
        )
        try db.createEntryEntryJoinTable(
            Homonym.self,
            of: \.base,
            to: \.homonym
        )
    }
}

extension DB.Orthographic {
    static func migrate(db: Database) throws {
        try db.createEntryEntryJoinTable(
            AlternativeSpelling.self,
            of: \.base,
            to: \.alternativeSpelling
        )
        try db.createEntryEntryJoinTable(
            Transliteration.self,
            of: \.base,
            to: \.transliteration
        )
    }
}

extension Database {
    func createEntryEntryJoinTable<T: StructuredQueries.Table>(
        _ table: T.Type,
        of tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, DB.Entry.ID>>,
        to tableTargetKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, DB.Entry.ID>>
    ) throws {
        try execute(sql:
            CreateJoinTable(
                table,
                DB.Entry.self,
                DB.Entry.self,
                of: tableBaseKeyPath,
                on: \.id,
                to: tableTargetKeyPath,
                id: \.id
            )
            .statement
        )
        try createIndex(table, on: tableBaseKeyPath)
        try createIndex(table, on: tableTargetKeyPath)
    }

    func createEntryJoinTable<T: StructuredQueries.Table, V: StructuredQueries.Table & Identifiable>(
        _ table: T.Type,
        _ target: V.Type,
        of tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, DB.Entry.ID>>,
        to tableTargetKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, V.ID>>,
        id targetIDKeyPath: KeyPath<V.TableColumns, TableColumn<V.TableColumns.QueryValue, V.ID>>
    ) throws where V.ID: QueryBindable {
        try execute(sql:
            CreateJoinTable(
                table,
                DB.Entry.self,
                V.self,
                of: tableBaseKeyPath,
                on: \.id,
                to: tableTargetKeyPath,
                id: targetIDKeyPath
            )
            .statement
        )
        try createIndex(table, on: tableBaseKeyPath)
        try createIndex(table, on: tableTargetKeyPath)
    }

    func createIndex<T: StructuredQueries.Table, IndexID: Hashable>(
        _ table: T.Type,
        on indexKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, IndexID>>
    ) throws {
        try execute(sql:
            CreateIndex<T, IndexID>(
                table,
                of: indexKeyPath
            )
            .statement
        )
    }
}
