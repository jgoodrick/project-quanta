//
//  WordFormController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import Dependencies
import SharingGRDB
import SwiftUI
import SwiftUINavigation

@Observable
final class WordFormController: Identifiable {
    var translations: [TranslationDraft] = []
    var focus: Field?
    var isDismissed = false
    var word: DB.Entry.Full.Draft

    @ObservationIgnored @Dependency(\.defaultDatabase) var database
    @ObservationIgnored @Dependency(\.uuid) var uuid

    struct TranslationDraft: Identifiable {
        let id: UUID
        var text = ""
    }

    enum Field: Hashable {
        case translation(TranslationDraft.ID)
        case text
    }

    init(
        word: DB.Entry.Full.Draft,
        focus: Field? = .text
    ) {
        self.word = word
        self.focus = focus
    }

    func deleteTranslations(atOffsets indices: IndexSet) {
        translations.remove(atOffsets: indices)
        if translations.isEmpty {
            translations.append(TranslationDraft(id: uuid()))
        }
        guard let firstIndex = indices.first
        else { return }
        let index = min(firstIndex, translations.count - 1)
        focus = .translation(translations[index].id)
    }

    func addTranslationButtonTapped() {
        let translation = TranslationDraft(id: uuid())
        translations.append(translation)
        focus = .translation(translation.id)
    }

    func cancelButtonTapped() {
        isDismissed = true
    }

    func saveButtonTapped() {
        translations.removeAll { translation in
            translation.text.allSatisfy(\.isWhitespace)
        }
        if translations.isEmpty {
            translations.append(WordFormController.TranslationDraft(id: uuid()))
        }
//        withErrorReporting {
//            try database.write { db in
//                guard let wordID = try DB.Entry.Full.upsert(word).returning(\.id).fetchOne(db)
//                else {
//                    reportIssue("Could not upsert sync-up.")
//                    return
//                }
//                try Translation.where { $0.wordID == wordID }.delete().execute(db)
//                for translation in translations {
//                    try Translation.insert(
//                        Translation.Draft(
//                            text: translation.text,
//                            wordID: wordID,
//                            languageID: "en"
//                        )
//                    )
//                    .execute(db)
//                }
//            }
//        }
        isDismissed = true
    }
}

struct WordForm: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: WordFormController.Field?
    @Bindable var controller: WordFormController

    var body: some View {
        Form {
            Section {
                TextField("Text", text: $controller.word.spelling.text)
                    .focused($focus, equals: .text)
                HStack {
                    Spacer()
                }
                SelectableLanguagePicker(selection: $controller.word.language.code)
            } header: {
                Text("Sync-up Info")
            }
            Section {
                ForEach($controller.translations) { $translation in
                    TextField("Name", text: $translation.text)
                        .focused($focus, equals: .translation(translation.id))
                }
                .onDelete { indices in
                    controller.deleteTranslations(atOffsets: indices)
                }

                Button("New translation") {
                    controller.addTranslationButtonTapped()
                }
            } header: {
                Text("Translations")
            }
        }
        .bind($controller.focus, to: $focus)
        .onChange(of: controller.isDismissed) {
            dismiss()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    controller.cancelButtonTapped()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    controller.saveButtonTapped()
                }
            }
        }
    }
}

extension Int {
    fileprivate var toDouble: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

struct SelectableLanguagePicker: View {
    @Binding var selection: String

    var body: some View {
        Picker("Language", selection: $selection) {
            ForEach(DB.Language.Name.BuiltIn.allCases) { language in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                    Label(language.text, systemImage: "flag")
                        .padding(4)
                }
                .fixedSize(horizontal: false, vertical: true)
                .tag(language.code)
            }
        }
    }
}

struct WordFormPreviews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WordForm(
                controller: WordFormController(
                    word: DB.Entry.Full.Draft(
                        entry: DB.Entry.Draft(
                            id: 0,
                            spelling: 0,
                            language: "en",
                            recorded: .now
                        ),
                        spelling: DB.Entry.Spelling.Draft(text: "Hello"),
                        language: DB.Language.Name(
                            code: "en",
                            text: "English"
                        )
                    )
                )
            )
        }
    }
}
