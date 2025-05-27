//
//  WordListController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import StructuredQueries
import SwiftUI
import SwiftUINavigation

@Observable
final class WordListController: HashableObject {
    var addWord: WordFormController?
    @ObservationIgnored @SharedReader(.fetch(DB.Entry.Slim.all)) var words: [DB.Entry.Slim.Value]
    @ObservationIgnored @Dependency(\.uuid) var uuid
    @ObservationIgnored @Dependency(\.defaultDatabase) var database

    init(addWord: WordFormController? = nil) {
        self.addWord = addWord
    }

    func addWordButtonTapped() {
//        addWord = withDependencies(from: self) {
//            WordFormController(word: Word.Draft(text: "", languageID: "en", recorded: .now))
//        }
    }
}

struct WordList: View {
    @State var controller = WordListController()

    var body: some View {
        List {
            ForEach(controller.words) { word in
                NavigationLink(value: AppController.Path.detail(WordDetailController(slim: word))) {
                    Card(controller: .init(slim: word))
                }
            }
        }
        .toolbar {
            Button {
                controller.addWordButtonTapped()
            } label: {
                Image(systemName: "plus")
            }
        }
        .navigationTitle("Words")
        .sheet(item: $controller.addWord) { wordFormController in
            NavigationStack {
                WordForm(controller: wordFormController)
                    .navigationTitle("New word")
            }
        }
    }
}

extension WordList {
    struct Card: View {
        let controller: Controller

        struct Controller {
            let entry: DB.Entry.Slim.Value
            @ObservationIgnored @SharedReader var details: DB.Entry.Full.Value

            init(slim: DB.Entry.Slim.Value) {
                self.entry = slim
                _details = SharedReader(
                    wrappedValue: DB.Entry.Full.Value(slim: slim),
                    .fetch(DB.Entry.Full(entry: slim.id), animation: .default)
                )
            }
        }

        var body: some View {
            Template(
                spelling: controller.details.spelling.text,
                translations: controller.details.translations.map(\.spelling.text)
            )
        }

        struct Template: View {
            let spelling: String
            let translations: [String]

            var body: some View {
                VStack(alignment: .leading) {
                    Text(spelling)
                        .font(.headline)
                    Spacer()
                    HStack {
                        ForEach(translations.enumerated().map(\.self), id: \.0) { (index, translation) in
                            Text(translation)
                        }
                    }
                    .font(.caption)
                }
                .padding()
            }
        }
    }
}

#Preview {
    let _ = DB.prepare()
    NavigationStack {
        WordList(controller: WordListController())
    }
}
