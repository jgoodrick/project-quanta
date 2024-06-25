
extension EntryDetailStore {
    static let mock: EntryDetailStore = {
        let result = EntryDetailStore()
        result.spelling = "кванти"
        result.image = .systemName("star.circle")
        result.tags = [
            .init(index: 0, title: "noun"),
            .init(index: 1, title: "plural"),
            .init(index: 2, title: "masculine"),
        ]
        result.pronunciation = .none
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
        result.notes = [
            .init(
                index: 1,
                value: "this word is really only used in physics contexts in Ukrainian"
            ),
        ]
        result.relatedEntries = [
            .init(index: 0, spelling: "Квантова"),
            .init(index: 1, spelling: "квантів"),
            .init(index: 2, spelling: "Квантова"),
        ]
        return result
    }()
}

