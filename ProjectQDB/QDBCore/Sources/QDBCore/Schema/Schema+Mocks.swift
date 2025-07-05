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
            DB.Entry(id: 1, spelling: "hello", language: "en", recorded: Mock.now())
            DB.Entry(id: 2, spelling: "world", language: "en", recorded: Mock.now())
            DB.Entry(id: 3, spelling: "goodbye", language: "en", recorded: Mock.now())
            DB.Entry(id: 4, spelling: "see you later", language: "en", recorded: Mock.now())
            DB.Entry(id: 100, spelling: "hola", language: "es", recorded: Mock.now())
            DB.Entry(id: 200, spelling: "mundo", language: "es", recorded: Mock.now())
            DB.Entry(id: 300, spelling: "adiós", language: "es", recorded: Mock.now())
            DB.Entry(id: 1000, spelling: "привіт", language: "uk", recorded: Mock.now())
            DB.Entry(id: 2000, spelling: "світ", language: "uk", recorded: Mock.now())
            DB.Entry(id: 3000, spelling: "пока", language: "uk", recorded: Mock.now())
            DB.Semantic.Synonym(base: 1, synonym: 4)
            DB.Semantic.Synonym(base: 1, synonym: 100)
            DB.Semantic.Synonym(base: 1, synonym: 1000)
            DB.Semantic.Synonym(base: 100, synonym: 1)
            DB.Semantic.Synonym(base: 100, synonym: 1000)
            DB.Semantic.Synonym(base: 1000, synonym: 1)
            DB.Semantic.Synonym(base: 1000, synonym: 100)
            DB.Semantic.Synonym(base: 2, synonym: 200)
            DB.Semantic.Synonym(base: 2, synonym: 2000)
            DB.Semantic.Synonym(base: 200, synonym: 2)
            DB.Semantic.Synonym(base: 200, synonym: 2000)
            DB.Semantic.Synonym(base: 2000, synonym: 2)
            DB.Semantic.Synonym(base: 2000, synonym: 200)
            DB.Semantic.Synonym(base: 3, synonym: 300)
            DB.Semantic.Synonym(base: 3, synonym: 3000)
            DB.Semantic.Synonym(base: 300, synonym: 3)
            DB.Semantic.Synonym(base: 300, synonym: 3000)
            DB.Semantic.Synonym(base: 3000, synonym: 3)
            DB.Semantic.Synonym(base: 3000, synonym: 300)
            
            DB.Entry.Keyword(id: 10000, text: "greeting", description: "said when meeting someone")
            DB.Entry.Keyword(id: 20000, text: "farewell", description: "said when departing")
            DB.Entry.Keyword(id: 30000, text: "interjection", description: "greeting, emotion, or reaction, often standing alone.")

            DB.Entry.Joins.EntryKeyword(entry: 1, keyword: 10000)
            DB.Entry.Joins.EntryKeyword(entry: 1, keyword: 30000)
            DB.Entry.Joins.EntryKeyword(entry: 3, keyword: 20000)
            DB.Entry.Joins.EntryKeyword(entry: 3, keyword: 30000)
            DB.Entry.Joins.EntryKeyword(entry: 4, keyword: 20000)
            DB.Entry.Joins.EntryKeyword(entry: 4, keyword: 30000)

            DB.Entry.Definition(id: 100000, text: "A word used to greet someone, attract attention, or express surprise.")
            DB.Entry.Definition(id: 200000, text: "The Earth and all life on it")
            DB.Entry.Definition(id: 200001, text: "Human civilization or society")
            DB.Entry.Definition(id: 300000, text: "Used when leaving or ending a conversation.")
            DB.Entry.Definition(id: 300001, text: "Can mark the end of a relationship, conversation, job, etc.")

            DB.Entry.Joins.EntryDefinition(entry: 1, definition: 100000)
            DB.Entry.Joins.EntryDefinition(entry: 2, definition: 200000)
            DB.Entry.Joins.EntryDefinition(entry: 2, definition: 200001)
            DB.Entry.Joins.EntryDefinition(entry: 3, definition: 300000)
            DB.Entry.Joins.EntryDefinition(entry: 3, definition: 300001)
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
            static let hello = DB.Entry(id: 1, spelling: "hello", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: 2, spelling: "world", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 3, spelling: "goodbye", language: language, recorded: Mock.now())
            static let seeYouLater = DB.Entry(id: 4, spelling: "see you later", language: language, recorded: Mock.now())
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
            static let hello = DB.Entry(id: 100, spelling: "hola", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: 200, spelling: "mundo", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 300, spelling: "adiós", language: language, recorded: Mock.now())
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
            static let hello = DB.Entry(id: 1000, spelling: "привіт", language: language, recorded: Mock.now())
            static let world = DB.Entry(id: 2000, spelling: "світ", language: language, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 3000, spelling: "пока", language: language, recorded: Mock.now())
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
