
import ComposableArchitecture
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct AddCustomLanguage {
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        var languageCode: String = ""
//        var scriptCode: String = ""
        var regionCode: String = ""
        var isShowingCustomLanguageCodeField: Bool = false
//        var isShowingCustomScriptCodeField: Bool = false
        var isShowingCustomRegionCodeField: Bool = false
        var isShowingCustomNameField: Bool = false
        var customNameForAllLanguages: String = ""
        
        var currentLocalizedName: String = ""
        var currentLanguageSelectedForLocalizedName: String? = nil
        var customLocalizedNamesByLanguageCode: [String: String] = [:]
        
        @Presents var destination: Destination.State?
        
        var resolvedBCP47Code: String? {
            
            guard !languageCode.isEmpty else { return nil }
            
            return [
                languageCode,
//                scriptCode,
                regionCode
            ].compactMap({ $0.isEmpty ? nil : $0 }).joined(separator: "-")
                        
        }

        var isValidForCreation: Bool {
            !languageCode.isEmpty
        }
        
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case creationConfirmedButtonTapped
        case addCustomNameButtonTapped
        case tappedCommonLanguageMenuItem(CommonLanguageCode?)
//        case tappedCommonScriptMenuItem(CommonScriptCode?)
        case tappedCommonRegionMenuItem(CommonRegionCode?)
        case saveLocalizedNameButtonTapped
        case tappedAddLocalizedNameMenuItem(CommonLanguageCode)
        case clearCustomNameSelectionButtonTapped
        case clearLocalizedNameButtonTapped(String)
        case clearCustomLanguageCodeButtonTapped
//        case clearCustomScriptCodeButtonTapped
        case clearCustomRegionCodeButtonTapped
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding, .destination: return .none
            case .creationConfirmedButtonTapped:
                
                guard let newCode = state.resolvedBCP47Code else {
                    
                    state.destination = .alert(.init(title: { .init("Language cannot be empty")}))
                    
                    return .none
                }
                
                do {
                    
                    let newLanguage = try Language(bcp47: newCode)
//                    newLanguage.customLocalizedNames = state.customLocalizedNamesByLanguageCode
                    state.db.ensureExistenceOf(language: newLanguage)
                    state.settings.languageSelectionList.append(newLanguage)
                    state.settings.focusedLanguage = newLanguage
                    
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
                
//            case .tappedCommonScriptMenuItem(let scriptCode):
//                
//                if let scriptCode {
//                    state.scriptCode = scriptCode.rawValue
//                    state.isShowingCustomScriptCodeField = false
//                } else {
//                    state.isShowingCustomScriptCodeField = true
//                }
//
//                return .none
//                
            case .tappedCommonRegionMenuItem(let regionCode):
                
                if let regionCode {
                    state.regionCode = regionCode.rawValue
                    state.isShowingCustomRegionCodeField = false
                } else {
                    state.isShowingCustomRegionCodeField = true
                }

                return .none
                
            case .saveLocalizedNameButtonTapped:
                
                guard let languageCode = state.currentLanguageSelectedForLocalizedName else { return .none }
                
                state.customLocalizedNamesByLanguageCode[languageCode] = state.currentLocalizedName
                
                state.currentLanguageSelectedForLocalizedName = .none
                state.currentLocalizedName = ""
                
                return .none
                
            case .tappedAddLocalizedNameMenuItem(let languageCode):
                
                state.isShowingCustomNameField = false
                state.customNameForAllLanguages = ""
                state.currentLanguageSelectedForLocalizedName = languageCode.rawValue
                
                return .none
                
            case .clearCustomNameSelectionButtonTapped:
                
                state.customNameForAllLanguages = ""
                state.isShowingCustomNameField = false
                
                return .none
                
            case .clearLocalizedNameButtonTapped(let code):
                
                state.customLocalizedNamesByLanguageCode[code] = nil
                
                return .none
                
            case .clearCustomLanguageCodeButtonTapped:
                
                state.languageCode = ""
                state.isShowingCustomLanguageCodeField = false
                
                return .none
                
//            case .clearCustomScriptCodeButtonTapped:
//
//                state.scriptCode = ""
//                state.isShowingCustomScriptCodeField = false
//
//                return .none
//                
            case .clearCustomRegionCodeButtonTapped:

                state.regionCode = ""
                state.isShowingCustomRegionCodeField = false

                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

fileprivate extension AlertState where Action == Never {
    static func failedToCreateLanguage(from resolved: String) -> Self {
        .init(title: { .init("Failed to create a language corresponding to \(resolved)")})
    }
}

struct AddCustomLanguageView: View {
    
    @SwiftUI.Bindable var store: StoreOf<AddCustomLanguage>
    
    @Environment(\.locale) var locale
    
    var body: some View {
        VStack {
            
            
            if let resolved = store.resolvedBCP47Code {
                HStack {
                    Text("BCP 47: ")
                    Text(resolved)
                }
            }
            
            HStack {
                Group {
                    VStack {
                        if store.isShowingCustomLanguageCodeField {
                            HStack {
                                TextField("Language", text: $store.languageCode)
                                Button(action: { store.send(.clearCustomLanguageCodeButtonTapped) }) {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                        } else {
                            HStack {
                                Menu(locale.localizedString(forLanguageCode: store.languageCode) ?? "Language") {
                                    Button("Custom") {
                                        store.send(.tappedCommonLanguageMenuItem(.none))
                                    }
                                    ForEach(CommonLanguageCode.allCases) { code in
                                        Button(code.displayName(for: locale)) {
                                            store.send(.tappedCommonLanguageMenuItem(code))
                                        }
                                    }
                                }
                                if !store.languageCode.isEmpty {
                                    Button(action: { store.send(.clearCustomLanguageCodeButtonTapped) }) {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                }
                            }
                        }
                    }
                    
//                    VStack {
//                        if store.isShowingCustomScriptCodeField {
//                            HStack {
//                                TextField("Code", text: $store.scriptCode)
//                                Button(action: { store.send(.clearCustomScriptCodeButtonTapped) }) {
//                                    Image(systemName: "xmark.circle.fill")
//                                }
//                            }
//                        } else {
//                            HStack {
//                                Menu(locale.localizedString(forScriptCode: store.scriptCode) ?? "Script") {
//                                    Button("Custom") {
//                                        store.send(.tappedCommonScriptMenuItem(.none))
//                                    }
//                                    ForEach(CommonScriptCode.allCases) { code in
//                                        Button(code.displayName(for: locale)) {
//                                            store.send(.tappedCommonScriptMenuItem(code))
//                                        }
//                                    }
//                                }
//                                if !store.scriptCode.isEmpty {
//                                    Button(action: { store.send(.clearCustomScriptCodeButtonTapped) }) {
//                                        Image(systemName: "xmark.circle.fill")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
                    VStack {
                        if store.isShowingCustomRegionCodeField {
                            HStack {
                                TextField("Code", text: $store.regionCode)
                                Button(action: { store.send(.clearCustomRegionCodeButtonTapped) }) {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                        } else {
                            HStack {
                                Menu(locale.localizedString(forRegionCode: store.regionCode) ?? "Region") {
                                    Button("Custom") {
                                        store.send(.tappedCommonRegionMenuItem(.none))
                                    }
                                    ForEach(CommonRegionCode.allCases) { code in
                                        Button(code.displayName(for: locale)) {
                                            store.send(.tappedCommonRegionMenuItem(code))
                                        }
                                    }
                                }
                                if !store.regionCode.isEmpty {
                                    Button(action: { store.send(.clearCustomRegionCodeButtonTapped) }) {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            if store.isShowingCustomNameField {
                HStack {
                    TextField("Custom Name (in all languages)", text: $store.customNameForAllLanguages)
                    Button(action: { store.send(.clearCustomNameSelectionButtonTapped) }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            } else if store.currentLanguageSelectedForLocalizedName == nil, store.customLocalizedNamesByLanguageCode.isEmpty {
                
                Button("+ Add Custom Name") {
                    store.send(.addCustomNameButtonTapped)
                }
                
            }

            ForEach(store.customLocalizedNamesByLanguageCode.keys.sorted(), id: \.self) { key in
                HStack {
                    Text("\(locale.localizedString(forLanguageCode: key) ?? key): \(store.customLocalizedNamesByLanguageCode[key] ?? "[none]")")
                    Button(action: { store.send(.clearLocalizedNameButtonTapped(key)) }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }

            if let code = store.currentLanguageSelectedForLocalizedName {
                HStack {
                    Text(locale.localizedString(forLanguageCode: code) ?? code)
                    TextField("Name", text: $store.currentLocalizedName)
                        .frame(maxWidth: 200)
                    Button("Save") {
                        store.send(.saveLocalizedNameButtonTapped)
                    }
                }
            } else if !store.isShowingCustomNameField {
                Menu("+ Add Localized Name") {
                    ForEach(CommonLanguageCode.allCases) { code in
                        Button(code.displayName(for: locale)) {
                            store.send(.tappedAddLocalizedNameMenuItem(code))
                        }
                    }
                }
            }


            Button("Create") {
                store.send(.creationConfirmedButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!store.isValidForCreation)
            .padding()
            
        }
        .presentationDetents([.medium])
        .textFieldStyle(.roundedBorder)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview { Preview }
private var Preview: some View {
    AddCustomLanguageView(store: .init(initialState: .init(), reducer: { AddCustomLanguage() }))
}

public enum CommonLanguageCode: String, Identifiable, CaseIterable {
    public var id: Self { self }
    public func displayName(for locale: Locale) -> String {
        locale.localizedString(forLanguageCode: rawValue) ?? rawValue
    }
    case Chinese = "zh"
    case Spanish = "es"
    case English = "en"
    case Hindi = "hi"
    case Arabic = "ar"
    case Bengali = "bn"
    case Portuguese = "pt"
    case Russian = "ru"
    case Japanese = "ja"
    case Punjabi = "pa"
    case German = "de"
    case Javanese = "jv"
    case Korean = "ko"
    case French = "fr"
    case Telugu = "te"
    case Marathi = "mr"
    case Tamil = "ta"
    case Vietnamese = "vi"
    case Urdu = "ur"
    case Italian = "it"
    case Turkish = "tr"
    case Persian = "fa"
    case Thai = "th"
    case Gujarati = "gu"
    case Kannada = "kn"
    case Polish = "pl"
    case Amharic = "am"
    case Burmese = "my"
    case Odia = "or"
    case Malayalam = "ml"
    case Sindhi = "sd"
    case Nepali = "ne"
    case Sinhala = "si"
    case Hausa = "ha"
    case Ukrainian = "uk"
    case Romanian = "ro"
    case Dutch = "nl"
    case Greek = "el"
    case Hungarian = "hu"
    case Azerbaijani = "az"
    case Hebrew = "he"
    case Uzbek = "uz"
    case Catalan = "ca"
    case Khmer = "km"
    case Tajik = "tg"
    case Somali = "so"
    case Czech = "cs"
    case Swedish = "sv"
    case Serbian = "sr"
    case Danish = "da"
    case Finnish = "fi"
    case Slovak = "sk"
    case Norwegian = "no"
    case Slovenian = "sl"
    case Croatian = "hr"
    case Lithuanian = "lt"
    case Latvian = "lv"
    case Ewe = "ee"
    case Afrikaans = "af"
    case Bulgarian = "bg"
    case Estonian = "et"
    case Macedonian = "mk"
    case Albanian = "sq"
    case Icelandic = "is"
    case Irish = "ga"
    case Maltese = "mt"
    case Welsh = "cy"
    case Scottish_Gaelic = "gd"
    case Armenian = "hy"
    case Georgian = "ka"
}

public enum CommonScriptCode: String, Identifiable, CaseIterable {
    public var id: Self { self }
    public func displayName(for locale: Locale) -> String {
        locale.localizedString(forScriptCode: rawValue) ?? rawValue
    }
    case Latin = "Latn"
    case Cyrillic = "Cyrl"
    case Arabic = "Arab"
    case Devanagari = "Deva"
    case Han_Simplified = "Hans"
    case Han_Traditional = "Hant"
    case Bengali = "Beng"
    case Gurmukhi = "Guru"
    case Japanese = "Jpan"
    case Korean = "Kore"
    case Greek = "Grek"
    case Ethiopic = "Ethi"
    case Hebrew = "Hebr"
    case Thaana = "Thaa"
    case Armenian = "Armn"
    case Unified_Canadian_Aboriginal_Syllabics = "Cans"
    case Cherokee = "Cher"
    case Coptic = "Copt"
    case Cypriot = "Cprt"
    case Georgian = "Geor"
    case Glagolitic = "Glag"
    case Gothic = "Goth"
    case Gujarati = "Gujr"
    case Hangul = "Hang"
    case Han = "Hani"
    case Old_Italic = "Ital"
    case Javanese = "Java"
    case Kayah_Li = "Kali"
    case Katakana = "Kana"
    case Khmer = "Khmr"
    case Kannada = "Knda"
    case Lao = "Lao"
    case Latin_Fraktur = "Latf"
    case Latin_Gaelic = "Latg"
    case Malayalam = "Mlym"
    case Mongolian = "Mong"
    case Myanmar = "Mymr"
    case N_Ko = "Nkoo"
    case Oriya = "Orya"
    case Runic = "Runr"
    case Sinhala = "Sinh"
    case Syriac = "Syrc"
    case Tamil = "Taml"
    case Telugu = "Telu"
    case Tifinagh = "Tfng"
    case Thai = "Thai"
    case Tibetan = "Tibt"
    case Vai = "Vaii"
    case Yi = "Yiii"
}

public enum CommonRegionCode: String, Identifiable, CaseIterable {
    public var id: Self { self }
    public func displayName(for locale: Locale) -> String {
        locale.localizedString(forRegionCode: rawValue) ?? rawValue
    }
    case United_States = "US"
    case China = "CN"
    case India = "IN"
    case Indonesia = "ID"
    case Brazil = "BR"
    case Pakistan = "PK"
    case Nigeria = "NG"
    case Bangladesh = "BD"
    case Russia = "RU"
    case Mexico = "MX"
    case Japan = "JP"
    case Philippines = "PH"
    case Ethiopia = "ET"
    case Egypt = "EG"
    case Vietnam = "VN"
    case Democratic_Republic_of_the_Congo = "CD"
    case Turkey = "TR"
    case Iran = "IR"
    case Germany = "DE"
    case Thailand = "TH"
    case United_Kingdom = "GB"
    case France = "FR"
    case Italy = "IT"
    case Tanzania = "TZ"
    case South_Africa = "ZA"
    case Myanmar = "MM"
    case Kenya = "KE"
    case South_Korea = "KR"
    case Colombia = "CO"
    case Spain = "Sp"
    case Uganda = "UG"
    case Argentina = "AR"
    case Ukraine = "UA"
    case Sudan = "SD"
    case Algeria = "DZ"
    case Poland = "PL"
    case Iraq = "IQ"
    case Canada = "CA"
    case Morocco = "MA"
    case Uzbekistan = "UZ"
    case Saudi_Arabia = "SA"
    case Afghanistan = "AF"
    case Malaysia = "MY"
    case Peru = "PE"
    case Angola = "AO"
    case Ghana = "GH"
    case Mozambique = "MZ"
    case Yemen = "YE"
    case Nepal = "NP"
    case Netherlands = "NL"
    case Romania = "RO"
    case Greece = "GR"
    case Hungary = "HU"
    case Israel = "IL"
    case Sweden = "SE"
    case Finland = "FI"
    case Norway = "NO"
    case Denmark = "DK"
    case Czech_Republic = "CZ"
    case Slovakia = "SK"
    case Bulgaria = "BG"
    case Serbia = "RS"
    case Croatia = "HR"
    case Slovenia = "SI"
    case Lithuania = "LT"
    case Latvia = "LV"
    case Estonia = "EE"
    case Macedonia = "MK"
    case Albania = "AL"
    case Iceland = "IS"
    case Ireland = "IE"
    case Malta = "MT"
    case Cyprus = "CY"
    case Armenia = "AM"
    case Georgia = "GE"
    case Portugal = "PT"
    case Sri_Lanka = "LK"
    case Azerbaijan = "AZ"
    case Cambodia = "KH"
    case Tajikistan = "TJ"
    case Somalia = "SO"
    case Togo = "TG"
}

struct BCP47CodeGenerator {
    let language: CommonLanguageCode
    let script: CommonScriptCode
    let region: CommonRegionCode
    
    init?(language: CommonLanguageCode, script: CommonScriptCode, region: CommonRegionCode) {
        self.language = language
        self.script = script
        self.region = region
        guard isValidCombination else {
            return nil
        }
    }
    
    var isValidCombination: Bool {
        switch language {
        case .English:
            return script == .Latin && [.United_States, .United_Kingdom].contains(region)
        case .Chinese:
            return (script == .Han_Simplified || script == .Han_Traditional) && region == .China
        case .Spanish:
            return script == .Latin && [.Spain, .Mexico, .Argentina].contains(region)
        case .Hindi:
            return script == .Devanagari && region == .India
        case .Arabic:
            return script == .Arabic && [.Egypt, .Saudi_Arabia].contains(region)
        case .Bengali:
            return script == .Bengali && region == .Bangladesh
        case .Portuguese:
            return script == .Latin && [.Brazil, .Portugal].contains(region)
        case .Russian:
            return script == .Cyrillic && region == .Russia
        case .Japanese:
            return script == .Japanese && region == .Japan
        case .Punjabi:
            return (script == .Gurmukhi || script == .Arabic) && region == .India
        case .German:
            return script == .Latin && region == .Germany
        case .Javanese:
            return script == .Javanese && region == .Indonesia
        case .Korean:
            return script == .Korean && region == .South_Korea
        case .French:
            return script == .Latin && region == .France
        case .Telugu:
            return script == .Telugu && region == .India
        case .Marathi:
            return script == .Devanagari && region == .India
        case .Tamil:
            return script == .Tamil && region == .India
        case .Vietnamese:
            return script == .Latin && region == .Vietnam
        case .Urdu:
            return script == .Arabic && region == .Pakistan
        case .Italian:
            return script == .Latin && region == .Italy
        case .Turkish:
            return script == .Latin && region == .Turkey
        case .Persian:
            return script == .Arabic && region == .Iran
        case .Thai:
            return script == .Thai && region == .Thailand
        case .Gujarati:
            return script == .Gujarati && region == .India
        case .Kannada:
            return script == .Kannada && region == .India
        case .Polish:
            return script == .Latin && region == .Poland
        case .Amharic:
            return script == .Ethiopic && region == .Ethiopia
        case .Burmese:
            return script == .Myanmar && region == .Myanmar
        case .Odia:
            return script == .Oriya && region == .India
        case .Malayalam:
            return script == .Malayalam && region == .India
        case .Sindhi:
            return script == .Arabic && region == .Pakistan
        case .Nepali:
            return script == .Devanagari && region == .Nepal
        case .Sinhala:
            return script == .Sinhala && region == .Sri_Lanka
        case .Hausa:
            return script == .Latin && region == .Nigeria
        case .Ukrainian:
            return script == .Cyrillic && region == .Ukraine
        case .Romanian:
            return script == .Latin && region == .Romania
        case .Dutch:
            return script == .Latin && region == .Netherlands
        case .Greek:
            return script == .Greek && region == .Greece
        case .Hungarian:
            return script == .Latin && region == .Hungary
        case .Azerbaijani:
            return script == .Latin && region == .Azerbaijan
        case .Hebrew:
            return script == .Hebrew && region == .Israel
        case .Uzbek:
            return script == .Latin && region == .Uzbekistan
        case .Catalan:
            return script == .Latin && region == .Spain
        case .Khmer:
            return script == .Khmer && region == .Cambodia
        case .Tajik:
            return script == .Cyrillic && region == .Tajikistan
        case .Somali:
            return script == .Latin && region == .Somalia
        case .Czech:
            return script == .Latin && region == .Czech_Republic
        case .Swedish:
            return script == .Latin && region == .Sweden
        case .Serbian:
            return script == .Cyrillic && region == .Serbia
        case .Danish:
            return script == .Latin && region == .Denmark
        case .Finnish:
            return script == .Latin && region == .Finland
        case .Slovak:
            return script == .Latin && region == .Slovakia
        case .Norwegian:
            return script == .Latin && region == .Norway
        case .Slovenian:
            return script == .Latin && region == .Slovenia
        case .Croatian:
            return script == .Latin && region == .Croatia
        case .Lithuanian:
            return script == .Latin && region == .Lithuania
        case .Latvian:
            return script == .Latin && region == .Latvia
        case .Ewe:
            return script == .Latin && region == .Togo
        case .Afrikaans:
            return script == .Latin && region == .South_Africa
        case .Bulgarian:
            return script == .Cyrillic && region == .Bulgaria
        case .Estonian:
            return script == .Latin && region == .Estonia
        case .Macedonian:
            return script == .Cyrillic && region == .Macedonia
        case .Albanian:
            return script == .Latin && region == .Albania
        case .Icelandic:
            return script == .Latin && region == .Iceland
        case .Irish:
            return script == .Latin && region == .Ireland
        case .Maltese:
            return script == .Latin && region == .Malta
        case .Welsh:
            return script == .Latin && region == .United_Kingdom
        case .Scottish_Gaelic:
            return script == .Latin && region == .United_Kingdom
        case .Armenian:
            return script == .Armenian && region == .Armenia
        case .Georgian:
            return script == .Georgian && region == .Georgia
        }
    }
}
