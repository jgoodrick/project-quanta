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

extension DB {
    static func createMockData(in db: Database) throws {
        try Mock.allLanguages.forEach {
            try Language.Name.insert($0).execute(db)
        }
        try Mock.allEntries.forEach {
            try Entry.insert($0).execute(db)
        }
        try Mock.allSpellings.forEach {
            try Entry.Spelling.insert($0).execute(db)
        }
        try Mock.allTranslations.forEach {
            try DB.Semantic.Synonym.insert($0).execute(db)
        }
    }
}

enum Mock {
    static let allLanguages: [DB.Language.Name] = [
        English.language,
        Spanish.language,
        Ukrainian.language
    ]

    static let allEntries: [DB.Entry] = English.Entry.all + Spanish.Entry.all + Ukrainian.Entry.all

    static let allSpellings: [DB.Entry.Spelling] = English.Spelling.all + Spanish.Spelling.all + Ukrainian.Spelling.all

    static let allTranslations: [DB.Semantic.Synonym] = English.Synonym.all + Spanish.Synonym.all + Ukrainian.Synonym.all

    static func now() -> Date {
        @Dependency(\.date) var date
        return date.now
    }

    enum English {
        static let language = DB.Language.Name(code: "en", text: "English")
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: 1, spelling: 1, language: language.code, recorded: Mock.now())
            static let world = DB.Entry(id: 2, spelling: 2, language: language.code, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 3, spelling: 3, language: language.code, recorded: Mock.now())
        }
        enum Spelling {
            static let all: [DB.Entry.Spelling] = [hello, world, goodbye]
            static let hello = DB.Entry.Spelling(id: 1, text: "hello")
            static let world = DB.Entry.Spelling(id: 2, text: "world")
            static let goodbye = DB.Entry.Spelling(id: 3, text: "goodbye")
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
        static let language = DB.Language.Name(code: "es", text: "Spanish")
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: 100, spelling: 100, language: language.code, recorded: Mock.now())
            static let world = DB.Entry(id: 200, spelling: 200, language: language.code, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 300, spelling: 300, language: language.code, recorded: Mock.now())
        }
        enum Spelling {
            static let all: [DB.Entry.Spelling] = [hello, world, goodbye]
            static let hello = DB.Entry.Spelling(id: 100, text: "hola")
            static let world = DB.Entry.Spelling(id: 200, text: "mundo")
            static let goodbye = DB.Entry.Spelling(id: 300, text: "adiós")
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
        static let language = DB.Language.Name(code: "uk", text: "Ukrainian")
        enum Entry {
            static let all: [DB.Entry] = [hello, world, goodbye]
            static let hello = DB.Entry(id: 1000, spelling: 1000, language: language.code, recorded: Mock.now())
            static let world = DB.Entry(id: 2000, spelling: 2000, language: language.code, recorded: Mock.now())
            static let goodbye = DB.Entry(id: 3000, spelling: 3000, language: language.code, recorded: Mock.now())
        }
        enum Spelling {
            static let all: [DB.Entry.Spelling] = [hello, world, goodbye]
            static let hello = DB.Entry.Spelling(id: 1000, text: "привіт")
            static let world = DB.Entry.Spelling(id: 2000, text: "світ")
            static let goodbye = DB.Entry.Spelling(id: 3000, text: "пока")
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
