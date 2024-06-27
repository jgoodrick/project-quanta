
import Combine

extension EntryDetailStore {
    static let mock: EntryDetailStore = .mockAll(except: [])
    static let mockEmpty: EntryDetailStore = .mockAll(except: ContextSection.allCases.reduce(into: [], { $0.insert($1) }))
    static func mockAll(
        spelling: String = "кванти",
        image: SplashImage? = .none,
        pronunciation: Pronunciation? = .none,
        except excluding: Set<ContextSection> = []
    ) -> EntryDetailStore {
        var result: EntryDetailStore.State = .init(
            spelling: spelling,
            draftSpelling: spelling,
            image: image,
            tags: [],
            pronunciation: pronunciation,
            collectionsMembership: [],
            translations: [],
            examples: [],
            notes: [],
            relatedEntries: []
        )
        result.spelling = spelling
        result.image = image
        if !excluding.contains(.tags) {
            result.tags = [
                .init(index: 0, title: "noun"),
                .init(index: 1, title: "plural"),
                .init(index: 2, title: "masculine"),
                .init(index: 3, title: "nominative"),
                .init(index: 4, title: "present"),
            ]
        }
        result.pronunciation = pronunciation
        if !excluding.contains(.translations) {
            result.translations = [
                .init(
                    value: "quanta",
                    language: .english
                ),
                .init(
                    value: "cuantos",
                    language: .spanish
                ),
            ]
        }
        if !excluding.contains(.examples) {
            result.examples = [
                .init(
                    index: 1,
                    value: "Учені досліджували властивості квантів у рамках нової теорії фізики.",
                    translations: [
                        .init(
                            exampleID: 1,
                            value: "Scientists studied the properties of quanta within the framework of a new theory in physics.",
                            language: .english
                        ),
                        .init(
                            exampleID: 1,
                            value: "Los científicos investigaron las propiedades de los cuantos en el marco de una nueva teoría de la física.",
                            language: .spanish
                        ),
                    ]
                ),
                .init(
                    index: 2,
                    value: "Квантова механіка описує поведінку частинок на рівні квантів.",
                    translations: [
                        .init(
                            exampleID: 2,
                            value: "Quantum mechanics describes the behavior of particles at the level of quanta.",
                            language: .english
                        ),
                    ]
                ),
            ]
        }
        if !excluding.contains(.notes) {
            result.notes = [
                .init(
                    index: 1,
                    value: "this word is really only used in physics contexts in Ukrainian"
                ),
            ]
        }
        if !excluding.contains(.collections) {
            result.collectionsMembership = [
                .init(title: "Cool Words"),
                .init(title: "To Learn"),
                .init(title: "Ukrainian Words"),
                .init(title: "Fun with Flags"),
                .init(title: "Nouns and Adjectives"),
            ]
        }
        if !excluding.contains(.relatedEntries) {
            result.relatedEntries = [
                .init(index: 0, spelling: "Квантова"),
                .init(index: 1, spelling: "квантів"),
                .init(index: 2, spelling: "Квантова"),
            ]
        }
        return EntryDetailStore.init(
            state: result,
            onAction: { EntryDetailStore.log(action: $0) }
        )
    }
}

