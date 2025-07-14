//
//  Schema+Mocks.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import Foundation
import Dependencies
import GRDB
import StructuredQueriesGRDB

#if DEBUG
extension Database {
    fileprivate func seedSampleData() throws {
        try seed {
            DB.Entry(id: .init(1), spelling: "hello", language: "en", recorded: Mock.now())
            DB.Entry(id: .init(2), spelling: "world", language: "en", recorded: Mock.now())
            DB.Entry(id: .init(3), spelling: "goodbye", language: "en", recorded: Mock.now())
            DB.Entry(id: .init(4), spelling: "see you later", language: "en", recorded: Mock.now())
            DB.Entry(id: .init(100), spelling: "hola", language: "es", recorded: Mock.now())
            DB.Entry(id: .init(200), spelling: "mundo", language: "es", recorded: Mock.now())
            DB.Entry(id: .init(300), spelling: "adiós", language: "es", recorded: Mock.now())
            DB.Entry(id: .init(1000), spelling: "привіт", language: "uk", recorded: Mock.now())
            DB.Entry(id: .init(2000), spelling: "світ", language: "uk", recorded: Mock.now())
            DB.Entry(id: .init(3000), spelling: "пока", language: "uk", recorded: Mock.now())
            DB.Semantic.Synonym(base: .init(1), synonym: .init(4))
            DB.Semantic.Synonym(base: .init(1), synonym: .init(100))
            DB.Semantic.Synonym(base: .init(1), synonym: .init(1000))
            DB.Semantic.Synonym(base: .init(100), synonym: .init(1))
            DB.Semantic.Synonym(base: .init(100), synonym: .init(1000))
            DB.Semantic.Synonym(base: .init(1000), synonym: .init(1))
            DB.Semantic.Synonym(base: .init(1000), synonym: .init(100))
            DB.Semantic.Synonym(base: .init(2), synonym: .init(200))
            DB.Semantic.Synonym(base: .init(2), synonym: .init(2000))
            DB.Semantic.Synonym(base: .init(200), synonym: .init(2))
            DB.Semantic.Synonym(base: .init(200), synonym: .init(2000))
            DB.Semantic.Synonym(base: .init(2000), synonym: .init(2))
            DB.Semantic.Synonym(base: .init(2000), synonym: .init(200))
            DB.Semantic.Synonym(base: .init(3), synonym: .init(300))
            DB.Semantic.Synonym(base: .init(3), synonym: .init(3000))
            DB.Semantic.Synonym(base: .init(300), synonym: .init(3))
            DB.Semantic.Synonym(base: .init(300), synonym: .init(3000))
            DB.Semantic.Synonym(base: .init(3000), synonym: .init(3))
            DB.Semantic.Synonym(base: .init(3000), synonym: .init(300))

            DB.Entry.Keyword(id: .init(10000), text: "greeting", description: "said when meeting someone")
            DB.Entry.Keyword(id: .init(20000), text: "farewell", description: "said when departing")
            DB.Entry.Keyword(id: .init(30000), text: "interjection", description: "greeting, emotion, or reaction, often standing alone.")

            DB.Entry.Joins.EntryKeyword(entry: .init(1), keyword: .init(10000))
            DB.Entry.Joins.EntryKeyword(entry: .init(1), keyword: .init(30000))
            DB.Entry.Joins.EntryKeyword(entry: .init(3), keyword: .init(20000))
            DB.Entry.Joins.EntryKeyword(entry: .init(3), keyword: .init(30000))
            DB.Entry.Joins.EntryKeyword(entry: .init(4), keyword: .init(20000))
            DB.Entry.Joins.EntryKeyword(entry: .init(4), keyword: .init(30000))

            DB.Entry.Definition(id: .init(100000), text: "A word used to greet someone, attract attention, or express surprise.")
            DB.Entry.Definition(id: .init(200000), text: "The Earth and all life on it")
            DB.Entry.Definition(id: .init(200001), text: "Human civilization or society")
            DB.Entry.Definition(id: .init(300000), text: "Used when leaving or ending a conversation.")
            DB.Entry.Definition(id: .init(300001), text: "Can mark the end of a relationship, conversation, job, etc.")

            DB.Entry.Joins.EntryDefinition(entry: .init(1), definition: .init(100000))
            DB.Entry.Joins.EntryDefinition(entry: .init(2), definition: .init(200000))
            DB.Entry.Joins.EntryDefinition(entry: .init(2), definition: .init(200001))
            DB.Entry.Joins.EntryDefinition(entry: .init(3), definition: .init(300000))
            DB.Entry.Joins.EntryDefinition(entry: .init(3), definition: .init(300001))
        }
    }
}

extension DB {
    static func createMockData(in db: Database) throws {
        try db.seedSampleData()
    }
}

enum Mock {
    static let allLanguages: [String] = [
        English.language,
        Spanish.language,
        Ukrainian.language
    ]

    static let allEntries: [DB.Entry] = English.Entry.all + Spanish.Entry.all + Ukrainian.Entry.all

    static let allTranslations: [DB.Semantic.Synonym] = English.Synonym.all + Spanish.Synonym.all + Ukrainian.Synonym.all

    static func now() -> Date {
        @Dependency(\.date) var date
        return date.now
    }

    enum English {
        static let language = "en"
        static let name = "English"
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: .init(1), spelling: "hello", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: .init(2), spelling: "world", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: .init(3), spelling: "goodbye", language: language, recorded: Mock.now())
            static let seeYouLater = DB.Entry(id: .init(4), spelling: "see you later", language: language, recorded: Mock.now())
        }
        enum Synonym {
            static let all: [DB.Semantic.Synonym] = [
                Spanish.hello,
                Spanish.world,
                Spanish.goodbye,

                Ukrainian.hello,
                Ukrainian.world,
                Ukrainian.goodbye,
            ]
            enum Spanish {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.hello.id,
                    synonym: Mock.Spanish.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.world.id,
                    synonym: Mock.Spanish.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.goodbye.id,
                    synonym: Mock.Spanish.Entry.goodbye.id
                )
            }
            enum Ukrainian {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.hello.id,
                    synonym: Mock.Ukrainian.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.world.id,
                    synonym: Mock.Ukrainian.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.English.Entry.goodbye.id,
                    synonym: Mock.Ukrainian.Entry.goodbye.id
                )
            }
        }
    }
    enum Spanish {
        static let language = "es"
        static let name = "Spanish"
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: .init(100), spelling: "hola", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: .init(200), spelling: "mundo", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: .init(300), spelling: "adiós", language: language, recorded: Mock.now())
        }
        enum Synonym {
            static let all: [DB.Semantic.Synonym] = [
                English.hello,
                English.world,
                English.goodbye,

                Ukrainian.hello,
                Ukrainian.world,
                Ukrainian.goodbye,
            ]
            enum English {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.hello.id,
                    synonym: Mock.English.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.world.id,
                    synonym: Mock.English.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.goodbye.id,
                    synonym: Mock.English.Entry.goodbye.id
                )
            }
            enum Ukrainian {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.hello.id,
                    synonym: Mock.Ukrainian.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.world.id,
                    synonym: Mock.Ukrainian.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.Spanish.Entry.goodbye.id,
                    synonym: Mock.Ukrainian.Entry.goodbye.id
                )
            }
        }
    }
    enum Ukrainian {
        static let language = "uk"
        static let name = "Ukrainian"
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: .init(1000), spelling: "привіт", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: .init(2000), spelling: "світ", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: .init(3000), spelling: "пока", language: language, recorded: Mock.now())
        }
        enum Synonym {
            static let all: [DB.Semantic.Synonym] = [
                Spanish.hello,
                Spanish.world,
                Spanish.goodbye,

                English.hello,
                English.world,
                English.goodbye,
            ]
            enum Spanish {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.hello.id,
                    synonym: Mock.Spanish.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.world.id,
                    synonym: Mock.Spanish.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.goodbye.id,
                    synonym: Mock.Spanish.Entry.goodbye.id
                )
            }
            enum English {
                static let hello: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.hello.id,
                    synonym: Mock.English.Entry.hello.id
                )
                static let world: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.world.id,
                    synonym: Mock.English.Entry.world.id
                )
                static let goodbye: DB.Semantic.Synonym = .init(
                    base: Mock.Ukrainian.Entry.goodbye.id,
                    synonym: Mock.English.Entry.goodbye.id
                )
            }
        }
    }
}

#endif
