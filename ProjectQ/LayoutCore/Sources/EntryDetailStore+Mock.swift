
import Foundation
import StructuralModel

extension EntryDetailStore {
    static let mock: EntryDetailStore = .mockAll(except: [])
    static let mockEmpty: EntryDetailStore = .mockAll(except: ContextSection.allCases.reduce(into: [], { $0.insert($1) }))
    static func mockAll(
        spelling: String = "кванти",
        language: Language = .ukrainian,
        image: SplashImage? = .none,
        pronunciation: Pronunciation? = .none,
        editMode: Bool = false,
        focused: EntryDetailStore.State.FocusedField? = nil,
        except excluding: Set<ContextSection> = []
    ) -> EntryDetailStore {
        var result: EntryDetailStore.State = .init(
            entry: .init(
                id: .mock(0),
                language: language,
                spelling: spelling
            ),
            image: image,
            tags: [],
            pronunciation: pronunciation,
            collectionsMembership: [],
            translations: [],
            translationDrafts: [],
            examples: [],
            exampleDrafts: [],
            notes: [],
            noteDrafts: [],
            relatedEntries: [],
            editMode: editMode ? .active : .inactive,
            focused: focused
        )
        result.image = image
        if !excluding.contains(.tags) {
            result.tags = [
                .init(id: .mock(1), title: "noun"),
                .init(id: .mock(2), title: "plural"),
                .init(id: .mock(3), title: "masculine"),
                .init(id: .mock(4), title: "nominative"),
                .init(id: .mock(5), title: "present"),
            ]
        }
        result.pronunciation = pronunciation
        if !excluding.contains(.translations) {
            result.translations = [
                .init(
                    id: .mock(11),
                    language: .english,
                    value: "quanta"
                ),
                .init(
                    id: .mock(22),
                    language: .spanish,
                    value: "cuantos"
                ),
            ]
        }
        if !excluding.contains(.examples) {
            let firstExampleID: UUID = .mock(111)
            let secondExampleID: UUID = .mock(222)
            result.examples = [
                .init(
                    id: firstExampleID,
                    language: .ukrainian,
                    value: "Учені досліджували властивості квантів у рамках нової теорії фізики.",
                    translations: [
                        Language.english.id: .init(
                            id: .init(
                                example: firstExampleID,
                                language: .english
                            ),
                            value: "Scientists studied the properties of quanta within the framework of a new theory in physics."
                        ),
                        Language.spanish.id: .init(
                            id: .init(
                                example: firstExampleID,
                                language: .spanish
                            ),
                            value: "Los científicos investigaron las propiedades de los cuantos en el marco de una nueva teoría de la física."
                        ),
                    ]
                ),
                .init(
                    id: secondExampleID,
                    language: .ukrainian,
                    value: "Квантова механіка описує поведінку частинок на рівні квантів.",
                    translations: [
                        Language.english.id: .init(
                            id: .init(
                                example: secondExampleID,
                                language: .english
                            ),
                            value: "Quantum mechanics describes the behavior of particles at the level of quanta."
                        ),
                    ]
                ),
            ]
        }
        if !excluding.contains(.notes) {
            result.notes = [
                .init(
                    id: .mock(1111),
                    value: "this word is really only used in physics contexts in Ukrainian"
                ),
            ]
        }
        if !excluding.contains(.collections) {
            result.collectionsMembership = [
                .init(id: .mock(11111), title: "Cool Words"),
                .init(id: .mock(22222), title: "To Learn"),
                .init(id: .mock(33333), title: "Ukrainian Words"),
                .init(id: .mock(44444), title: "Fun with Flags"),
                .init(id: .mock(55555), title: "Nouns and Adjectives"),
            ]
        }
        if !excluding.contains(.relatedEntries) {
            result.relatedEntries = [
                .init(id: .mock(000000), spelling: "Квантова"),
                .init(id: .mock(111111), spelling: "квантів"),
                .init(id: .mock(222222), spelling: "Квантова"),
            ]
        }
        return EntryDetailStore.init(
            state: result,
            onAction: { EntryDetailStore.log(action: $0) }
        )
    }
}

