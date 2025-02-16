
import AppModel
import ComposableArchitecture
import Foundation
import LayoutCore
import StructuralModel
import SwiftUI

@Reducer
struct AddCustomLanguage {
    @ObservableState
    struct State: Equatable {

        @Shared(.model) var model
        @Shared(.settings) var settings

        var languageCode: String = ""
        var scriptCode: String = ""
        var regionCode: String = ""
        var isShowingCustomLanguageCodeField: Bool = false
        var isShowingCustomScriptCodeField: Bool = false
        var isShowingCustomRegionCodeField: Bool = false
        var isShowingCustomNameField: Bool = false
        var customNameForAllLanguages: String = ""

        var localizedNameInput: String = ""
        var localizedNameLanguageCode: String? = nil
        var localizedNamesByLanguageCode: [Language.ID: String] = [:]

        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Never>)
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case creationConfirmedButtonTapped
        case addCustomNameButtonTapped
        case tappedCommonLanguageMenuItem(CommonLanguageCode?)
        case tappedCommonScriptMenuItem(CommonScriptCode?)
        case tappedCommonRegionMenuItem(CommonRegionCode?)
        case saveLocalizedNameButtonTapped
        case tappedLocalizeMenuItem(CommonLanguageCode)
        case clearCustomNameSelectionButtonTapped
        case clearLocalizedNameButtonTapped(Language.ID)
        case clearCustomLanguageCodeButtonTapped
        case clearCustomScriptCodeButtonTapped
        case clearCustomRegionCodeButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .creationConfirmedButtonTapped:
                
                guard let newCode = state.resolved?.value else {

                    state.destination = .alert(.init(title: { .init("Language cannot be empty")}))
                    
                    return .none
                }
                
                do {
                    
                    let newLanguage = try Language(bcp47: newCode)
//                    newLanguage.customLocalizedNames = state.localizedNamesByLanguageCode
                    state.model.ensureExistenceOf(language: newLanguage)
                    _ = state.$settings.withLock({ $0.languageSelectionList.append(newLanguage) })
//                    state.model.settings.focusedLanguage = newLanguage
                    
                } catch {
                    
                    state.destination = .alert(.failedToCreateLanguage(from: newCode))
                    
                }
                
                return .run { _ in
                    @Dependency(\.dismiss) var dismiss
                    await dismiss()
                }
                
            case .addCustomNameButtonTapped:
                
                state.isShowingCustomNameField = true
                
                return .none
             
            case .tappedCommonLanguageMenuItem(let languageCode):
                
                if let languageCode {
                    state.languageCode = languageCode.rawValue
                    state.isShowingCustomLanguageCodeField = false
                } else {
                    state.isShowingCustomLanguageCodeField = true
                }
                
                return .none
                
            case .tappedCommonScriptMenuItem(let scriptCode):
                
                if let scriptCode {
                    state.scriptCode = scriptCode.rawValue
                    state.isShowingCustomScriptCodeField = false
                } else {
                    state.isShowingCustomScriptCodeField = true
                }

                return .none
                
            case .tappedCommonRegionMenuItem(let regionCode):
                
                if let regionCode {
                    state.regionCode = regionCode.rawValue
                    state.isShowingCustomRegionCodeField = false
                } else {
                    state.isShowingCustomRegionCodeField = true
                }

                return .none
                
            case .saveLocalizedNameButtonTapped:
                
                guard let code = state.localizedNameLanguageCode else { return .none }

                do {
                    let languageID = try Language.ID(bcp47: code)

                    state.localizedNamesByLanguageCode[languageID] = state.localizedNameInput

                    state.localizedNameLanguageCode = .none
                    state.localizedNameInput = ""

                } catch {
                    reportIssue(error)
                }
                
                return .none

            case .tappedLocalizeMenuItem(let languageCode):
                
                state.isShowingCustomNameField = false
                state.customNameForAllLanguages = ""
                state.localizedNameLanguageCode = languageCode.rawValue

                return .none
                
            case .clearCustomNameSelectionButtonTapped:
                
                state.customNameForAllLanguages = ""
                state.isShowingCustomNameField = false
                
                return .none
                
            case .clearLocalizedNameButtonTapped(let code):
                
                state.localizedNamesByLanguageCode[code] = nil

                return .none
                
            case .clearCustomLanguageCodeButtonTapped:
                
                state.languageCode = ""
                state.isShowingCustomLanguageCodeField = false
                
                return .none
                
            case .clearCustomScriptCodeButtonTapped:

                state.scriptCode = ""
                state.isShowingCustomScriptCodeField = false

                return .none
                
            case .clearCustomRegionCodeButtonTapped:

                state.regionCode = ""
                state.isShowingCustomRegionCodeField = false

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AddCustomLanguage.State {
    var generator: BCP47CodeGenerator {
        .init(
            language: languageCode,
            script: scriptCode,
            region: regionCode
        )
    }

    var resolved: ResolvedBCP47Code? {
        generator.resolved
    }

    func valueAlreadyExists(for bcp47: String) -> Bool {
        model.languages(.all).contains(where: { $0.bcp47 == .init(rawValue: bcp47) })
    }

    var isValidForCreation: Bool {
        guard let resolvedValue = resolved?.value else { return false }
        return valueAlreadyExists(for: resolvedValue)
    }

    func displayName(for commonLanguageCode: CommonLanguageCode) -> String? {
        do {
            let language = try Language(bcp47: commonLanguageCode.rawValue)
            return model.displayName(for: language)
        } catch {
            reportIssue(error)
            return nil
        }
    }

    func displayName(for commonScriptCode: CommonScriptCode) -> String? {
        do {
            let language = try Language(bcp47: commonScriptCode.rawValue)
            return model.displayName(for: language)
        } catch {
            reportIssue(error)
            return nil
        }
    }

    func displayName(for commonRegionCode: CommonRegionCode) -> String? {
        do {
            let language = try Language(bcp47: commonRegionCode.rawValue)
            return model.displayName(for: language)
        } catch {
            reportIssue(error)
            return nil
        }
    }

    var availableLanguages: [CommonLanguageCode] {
        CommonLanguageCode.allCases
    }

    var availableScripts: [CommonScriptCode] {
        switch resolved?.language {
        case .common(let commonLanguage):
            commonLanguage.relevantScripts
        default:
            []
        }
    }

    var availableRegions: [CommonRegionCode] {
        switch resolved?.language {
        case .common(let commonLanguage):
            commonLanguage.relevantRegions
        default:
            []
        }
    }

}

fileprivate extension AlertState where Action == Never {
    static func failedToCreateLanguage(from resolved: String) -> Self {
        .init(title: { .init("Failed to create a language corresponding to \(resolved)")})
    }
}

struct AddCustomLanguageView: View {
    
    @Bindable var store: StoreOf<AddCustomLanguage>

    var resolvedLanguageID: ResolvedLanguageID? {
        ResolvedLanguageID(store: store)
    }
    struct ResolvedLanguageID: View {
        let store: StoreOf<AddCustomLanguage>

        @Environment(\.locale) private var locale

        var body: some View {
            if let resolvedCode = store.resolved?.value {
                Text("Draft:")
                    .padding(.top)

                HStack {
                    if let title = locale.localizedString(forIdentifier: resolvedCode) {
                        Text("\(title) (\(resolvedCode))")
                    } else {
                        Text(resolvedCode)
                    }

//                    customLanguageNameEditor
                }
            } else {
                Text("Add a new language below")
                    .font(.headline)
            }
        }
    }

    var body: some View {
        VStack(spacing: 32) {

            VStack {
                Text("Already Added:")
                ForEach(store.model.languages(.all)) { language in
                    Text("\(store.model.displayName(for: language)) (\(language.bcp47.rawValue))")
                }
            }

            resolvedLanguageID

            VStack {
                languageIDEditor

                Button("Create") {
                    store.send(.creationConfirmedButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!store.isValidForCreation)
            }
        }
        .padding()
        .presentationDetents([.medium])
        #if os(tvOS)
        .textFieldStyle(.automatic)
        #elseif !os(watchOS)
        .textFieldStyle(.roundedBorder)
        #endif
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

extension AddCustomLanguageView {
    var languageIDEditor: LanguageIDEditor {
        LanguageIDEditor(store: store)
    }
    struct LanguageIDEditor: View {
        @Bindable var store: StoreOf<AddCustomLanguage>

        struct ClearableCustomPicker<Option>: View {
            let title: String
            let onCustomSelected: () -> Void
            let availableOptions: [Option]
            let disabledReason: (Option) -> String?
            let selectedOption: Option?
            let optionTitle: (Option) -> String?
            let onOptionSelected: (Option) -> Void
            let onClear: () -> Void

            @Binding var shouldShowCustomField: Bool
            @Binding var custom: String
            let onCustomClear: () -> Void

            var customField: CustomField {
                .init(title: title, text: $custom, onClear: onCustomClear)
            }

            struct CustomField: View {
                let title: String
                @Binding var text: String
                let onClear: () -> Void

                var body: some View {
                    HStack {
                        TextField(title, text: $text)
                        Button(action: onClear) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
            }

            var customPicker: CustomPicker {
                CustomPicker(
                    fallbackTitle: title,
                    onCustomSelected: onCustomSelected,
                    availableOptions: availableOptions,
                    disabledReason: disabledReason,
                    selectedOption: selectedOption,
                    optionTitle: optionTitle,
                    onOptionSelected: onOptionSelected,
                    onClear: onClear
                )
            }
            struct CustomPicker: View {
                let fallbackTitle: String
                let onCustomSelected: () -> Void
                let availableOptions: [Option]
                let disabledReason: (Option) -> String?
                let selectedOption: Option?
                let optionTitle: (Option) -> String?
                let onOptionSelected: (Option) -> Void
                let onClear: () -> Void

                struct Cell: View {
                    let title: String
                    let disabledTitle: String?
                    let action: () -> Void
                    var body: some View {
                        if let disabledTitle {
                            Button(disabledTitle, action: {})
                                .disabled(true)
                        } else {
                            Button(title, action: action)
                        }
                    }
                }

                var sortedOptions: [SortableOption] {
                    availableOptions.compactMap({
                        guard let title = optionTitle($0) else { return nil }
                        return SortableOption(title: title, option: $0)
                    })
                    .sorted(by: \.title)
                }
                struct SortableOption: Identifiable {
                    var id: String { title }
                    let title: String
                    let option: Option
                }

                var body: some View {
                    HStack {
                        #if !os(watchOS)
                        Menu {
                            Button("Custom", action: onCustomSelected)
                            ForEach(sortedOptions) { sorted in
                                Cell(
                                    title: sorted.title,
                                    disabledTitle: disabledReason(sorted.option).map({
                                        "\(sorted.title) (\($0))"
                                    })
                                ) {
                                    onOptionSelected(sorted.option)
                                }
                            }
                        } label: {
                            Text(selectedOption.flatMap(optionTitle) ?? fallbackTitle)
                                .fixedSize()
                        }
                        #endif
                        if selectedOption != nil {
                            Button(action: onClear) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                }
            }

            var body: some View {
                VStack {
                    if shouldShowCustomField {
                        customField
                    } else {
                        customPicker
                    }
                }
            }
        }

        var languageField: LanguageField {
            LanguageField(store: store)
        }
        struct LanguageField: View {
            @Bindable var store: StoreOf<AddCustomLanguage>

            @Environment(\.locale) private var locale

            var body: some View {
                ClearableCustomPicker<CommonLanguageCode>.init(
                    title: "Choose Language",
                    onCustomSelected: {
                        store.send(.tappedCommonLanguageMenuItem(.none))
                    },
                    availableOptions: CommonLanguageCode.allCases,
                    disabledReason: { _ in nil },
                    selectedOption: CommonLanguageCode(rawValue: store.languageCode),
                    optionTitle: store.state.displayName(for:),
                    onOptionSelected: {
                        store.send(.tappedCommonLanguageMenuItem($0))
                    },
                    onClear: {
                        store.send(.clearCustomLanguageCodeButtonTapped)
                    },
                    shouldShowCustomField: $store.isShowingCustomLanguageCodeField,
                    custom: $store.languageCode,
                    onCustomClear: {
                        store.send(.clearCustomLanguageCodeButtonTapped)
                    }
                )
            }
        }

        var scriptField: ScriptField {
            ScriptField(store: store)
        }
        struct ScriptField: View {
            @Bindable var store: StoreOf<AddCustomLanguage>

            @Environment(\.locale) private var locale

            var body: some View {
                ClearableCustomPicker<CommonScriptCode>.init(
                    title: "Specify Script",
                    onCustomSelected: {
                        store.send(.tappedCommonScriptMenuItem(.none))
                    },
                    availableOptions: store.availableScripts,
                    disabledReason: { _ in nil },
                    selectedOption: CommonScriptCode(rawValue: store.scriptCode),
                    optionTitle: store.state.displayName(for:),
                    onOptionSelected: {
                        store.send(.tappedCommonScriptMenuItem($0))
                    },
                    onClear: {
                        store.send(.clearCustomScriptCodeButtonTapped)
                    },
                    shouldShowCustomField: $store.isShowingCustomScriptCodeField,
                    custom: $store.scriptCode,
                    onCustomClear: {
                        store.send(.clearCustomScriptCodeButtonTapped)
                    }
                )
            }
        }

        var regionField: RegionField {
            RegionField(store: store)
        }
        struct RegionField: View {
            @Bindable var store: StoreOf<AddCustomLanguage>

            @Environment(\.locale) private var locale

            var body: some View {
                ClearableCustomPicker<CommonRegionCode>.init(
                    title: "Add Region",
                    onCustomSelected: {
                        store.send(.tappedCommonRegionMenuItem(.none))
                    },
                    availableOptions: store.availableRegions,
                    disabledReason: { _ in nil },
                    selectedOption: CommonRegionCode(rawValue: store.regionCode),
                    optionTitle: store.state.displayName(for:),
                    onOptionSelected: {
                        store.send(.tappedCommonRegionMenuItem($0))
                    },
                    onClear: {
                        store.send(.clearCustomRegionCodeButtonTapped)
                    },
                    shouldShowCustomField: $store.isShowingCustomRegionCodeField,
                    custom: $store.regionCode,
                    onCustomClear: {
                        store.send(.clearCustomRegionCodeButtonTapped)
                    }
                )
            }
        }

        var body: some View {
            HStack {
                Group {

                    languageField

                    if store.resolved?.language != nil {

                        regionField

                        scriptField

                    }

                }
                .padding()
            }
        }
    }
}

extension AddCustomLanguageView.ResolvedLanguageID {
    var customLanguageNameEditor: CustomLanguageNameEditor {
        CustomLanguageNameEditor(store: store)
    }
    struct CustomLanguageNameEditor: View {
        @Bindable var store: StoreOf<AddCustomLanguage>

        @Environment(\.locale) private var locale

        var localizeButton: LocalizeButton {
            LocalizeButton(store: store)
        }
        struct LocalizeButton: View {
            let store: StoreOf<AddCustomLanguage>

            var body: some View {
                #if !os(watchOS)
                Menu("Localize") {
                    ForEach(store.availableLanguages) { code in
                        Button(code.displayName(for: .current)) {
                            store.send(.tappedLocalizeMenuItem(code))
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                #endif
            }
        }

        var body: some View {
            if store.isShowingCustomNameField {
                HStack {
                    TextField("Custom Name", text: $store.customNameForAllLanguages)

//                    localizeButton

                    Button(action: { store.send(.clearCustomNameSelectionButtonTapped) }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding()

//                ForEach(store.localizedNamesByLanguageCode.keys.sorted(), id: \.self) { key in
//                    HStack {
//                        Text("\(locale.localizedString(forLanguageCode: key.rawValue) ?? key.rawValue): \(store.localizedNamesByLanguageCode[key] ?? "[none]")")
//                        Button(action: { store.send(.clearLocalizedNameButtonTapped(key)) }) {
//                            Image(systemName: "xmark.circle.fill")
//                        }
//                    }
//                }

                if let code = store.localizedNameLanguageCode {
                    HStack {
                        Text(locale.localizedString(forLanguageCode: code) ?? code)
                        TextField("Name", text: $store.localizedNameInput)
                            .frame(maxWidth: 200)
                        Button("Save") {
                            store.send(.saveLocalizedNameButtonTapped)
                        }
                    }
                } else {
                }

            } else if store.localizedNameLanguageCode == nil, store.localizedNamesByLanguageCode.isEmpty {

                Button("Edit") {
                    store.send(.addCustomNameButtonTapped)
                }

            }
        }
    }
}

#Preview {
    @Shared(.model) var model = .init()
    AddCustomLanguageView(store: .init(
        initialState: .init(),
        reducer: { AddCustomLanguage() }
    ))
    .task {
        await model.prepareSharedValues()
    }
}
