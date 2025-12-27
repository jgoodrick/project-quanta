//
//  WordDetail.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SwiftUI
import UIComponents

enum Capitalization {
    case capitalized
    case lowercase
}

package struct WordDetail: View {
    let model: Model
    
    struct Model {
        let id: UUID
        let spelling: Spelling
        let language: Language
        let recorded: Date
        let translations: [Translation]
        let alternativeSpellings: [Spelling]
        let additionalLanguages: [Language]
        let locale: Locale
    }
    
    struct Spelling: Identifiable {
        let id: UUID
        let text: String
    }
    
    struct Translation: Identifiable {
        let id: UUID
        let spelling: Spelling
        let language: Language
    }
    
    struct Language: Identifiable {
        let id: UUID
        let title: (Capitalization) -> String
    }
    
    package var body: some View {
        List {
            LanguagesSection(
                model: .init(
                    language: model.language,
                    additionalLanguages: model.additionalLanguages
                )
            )
            
            if !model.alternativeSpellings.isEmpty {
                AlternativeSpellingsSection(
                    models: model.alternativeSpellings
                )
            }
            
//            if !model.translations.isEmpty {
//                TranslationsSection(
//                    models: model.translations
//                )
//            }
//            
//            if !model.notes.isEmpty {
//                NotesSection(
//                    models: model.notes
//                )
//            }
//            
//            if !model.roots.isEmpty {
//                RootsSection(
//                    models: model.roots
//                )
//            }
        }
//        .navigationTitle("\(model.entry.spelling)")
    }
    
    struct LanguagesSection: View {
        let model: Model
        
        struct Model {
            let language: Language
            let additionalLanguages: [Language]
        }
        
        var body: some View {
            Section("Language") {
                Text(model.language.title(.capitalized))
                
                if !model.additionalLanguages.isEmpty {
                    Text("Also used in:")
                    
                    ForEach(model.additionalLanguages) { additionalLanguage in
                        Text(additionalLanguage.title(.capitalized))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    struct AlternativeSpellingsSection: View {
        let models: [Spelling]
        
        var body: some View {
            Section("Alternative Spellings:") {
//                ForEach(models, content: Cell.init(model:))
            }
        }
        
        struct Cell: View {
            let model: Model
            
            struct Model {
                let spelling: String
            }
            
            var body: some View {
//                Text(model.spelling.text)
            }
        }
        
        struct TranslationsSection: View {
            let models: [Cell.Model]
            
            var body: some View {
                Section("Translations:") {
//                    ForEach(models, content: Cell.init(model:))
                }
            }
            
            struct Cell: View {
                let model: Model
                
                struct Model {
                    let spelling: String
                    let language: String
                    let locale: Locale
                }
                
                @State private var text: String
                
                init(model: Model) {
                    self.model = model
                    self._text = .init(wrappedValue: model.spelling)
                }
                
                var interpolatedLanguage: String {
                    model.locale.interpolatableLanguageName(
                        of: model.language,
                        capitalized: true
                    )
                }
                
                var title: String {
                    "\(interpolatedLanguage)Translation"
                }
                
                var body: some View {
                    TextField(title, text: $text)
                }
            }
        }
        
        struct NotesSection: View {
            let models: [Cell.Model]
            
            var body: some View {
                Section("Notes") {
//                    ForEach(model.notes, content: Cell.init)
                }
            }
            
            struct Cell: View {
                let model: Model
                
                struct Model {
                    let text: String
                }
                
                @State private var text: String
                
                init(model: Model) {
                    self.model = model
                    self._text = .init(wrappedValue: model.text)
                }
                
                var body: some View {
                    TextEditor(text: $text)
                }
            }
        }
        
        struct RootsSection: View {
            let models: [Cell.Model]
            
            var body: some View {
                Section("Roots") {
//                    ForEach(model.notes, content: Cell.init)
                }
            }
            
            struct Cell: View {
                let model: Model
                
                struct Model {
                    let spelling: Spelling
                }
                
                var body: some View {
                    Text(model.spelling.text)
                }
            }
        }
    }
}

#Preview {
    WordDetail(
        model: .init(
            id: .init(),
            spelling: WordDetail.Spelling(
                id: .init(),
                text: "spelling"
            ),
            language: WordDetail.Language(
                id: .init(),
                title: { _ in "Spelling"}
            ),
            recorded: .now,
            translations: [],
            alternativeSpellings: [],
            additionalLanguages: [],
            locale: .current
        )
    )
}
