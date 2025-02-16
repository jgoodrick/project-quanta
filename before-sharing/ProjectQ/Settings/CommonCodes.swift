//
//  CommonCodes.swift
//  ProjectQ
//
//  Created by Goodrick,Joseph on 1/4/25.
//

import Foundation

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

    var relevantScripts: [CommonScriptCode] {
        switch self {
        case .English:
            [.Latin]
        case .Chinese:
            [.Han_Simplified, .Han_Traditional]
        case .Spanish:
            [.Latin]
        case .Hindi:
            [.Devanagari]
        case .Arabic:
            [.Arabic]
        case .Bengali:
            [.Bengali]
        case .Portuguese:
            [.Latin]
        case .Russian:
            [.Cyrillic]
        case .Japanese:
            [.Japanese]
        case .Punjabi:
            [.Gurmukhi, .Arabic]
        case .German:
            [.Latin]
        case .Javanese:
            [.Javanese]
        case .Korean:
            [.Korean]
        case .French:
            [.Latin]
        case .Telugu:
            [.Telugu]
        case .Marathi:
            [.Devanagari]
        case .Tamil:
            [.Tamil]
        case .Vietnamese:
            [.Latin]
        case .Urdu:
            [.Arabic]
        case .Italian:
            [.Latin]
        case .Turkish:
            [.Latin]
        case .Persian:
            [.Arabic]
        case .Thai:
            [.Thai]
        case .Gujarati:
            [.Gujarati]
        case .Kannada:
            [.Kannada]
        case .Polish:
            [.Latin]
        case .Amharic:
            [.Ethiopic]
        case .Burmese:
            [.Myanmar]
        case .Odia:
            [.Oriya]
        case .Malayalam:
            [.Malayalam]
        case .Sindhi:
            [.Arabic]
        case .Nepali:
            [.Devanagari]
        case .Sinhala:
            [.Sinhala]
        case .Hausa:
            [.Latin]
        case .Ukrainian:
            [.Cyrillic]
        case .Romanian:
            [.Latin]
        case .Dutch:
            [.Latin]
        case .Greek:
            [.Greek]
        case .Hungarian:
            [.Latin]
        case .Azerbaijani:
            [.Latin]
        case .Hebrew:
            [.Hebrew]
        case .Uzbek:
            [.Latin]
        case .Catalan:
            [.Latin]
        case .Khmer:
            [.Khmer]
        case .Tajik:
            [.Cyrillic]
        case .Somali:
            [.Latin]
        case .Czech:
            [.Latin]
        case .Swedish:
            [.Latin]
        case .Serbian:
            [.Cyrillic]
        case .Danish:
            [.Latin]
        case .Finnish:
            [.Latin]
        case .Slovak:
            [.Latin]
        case .Norwegian:
            [.Latin]
        case .Slovenian:
            [.Latin]
        case .Croatian:
            [.Latin]
        case .Lithuanian:
            [.Latin]
        case .Latvian:
            [.Latin]
        case .Ewe:
            [.Latin]
        case .Afrikaans:
            [.Latin]
        case .Bulgarian:
            [.Cyrillic]
        case .Estonian:
            [.Latin]
        case .Macedonian:
            [.Cyrillic]
        case .Albanian:
            [.Latin]
        case .Icelandic:
            [.Latin]
        case .Irish:
            [.Latin]
        case .Maltese:
            [.Latin]
        case .Welsh:
            [.Latin]
        case .Scottish_Gaelic:
            [.Latin]
        case .Armenian:
            [.Armenian]
        case .Georgian:
            [.Georgian]
        }
    }

    var relevantRegions: [CommonRegionCode] {
        switch self {
        case .English:
            [.United_States, .United_Kingdom]
        case .Chinese:
            [.China]
        case .Spanish:
            [.Spain, .Mexico, .Argentina]
        case .Hindi:
            [.India]
        case .Arabic:
            [.Egypt, .Saudi_Arabia]
        case .Bengali:
            [.Bangladesh]
        case .Portuguese:
            [.Brazil, .Portugal]
        case .Russian:
            [.Russia]
        case .Japanese:
            [.Japan]
        case .Punjabi:
            [.India]
        case .German:
            [.Germany]
        case .Javanese:
            [.Indonesia]
        case .Korean:
            [.South_Korea]
        case .French:
            [.France]
        case .Telugu:
            [.India]
        case .Marathi:
            [.India]
        case .Tamil:
            [.India]
        case .Vietnamese:
            [.Vietnam]
        case .Urdu:
            [.Pakistan]
        case .Italian:
            [.Italy]
        case .Turkish:
            [.Turkey]
        case .Persian:
            [.Iran]
        case .Thai:
            [.Thailand]
        case .Gujarati:
            [.India]
        case .Kannada:
            [.India]
        case .Polish:
            [.Poland]
        case .Amharic:
            [.Ethiopia]
        case .Burmese:
            [.Myanmar]
        case .Odia:
            [.India]
        case .Malayalam:
            [.India]
        case .Sindhi:
            [.Pakistan]
        case .Nepali:
            [.Nepal]
        case .Sinhala:
            [.Sri_Lanka]
        case .Hausa:
            [.Nigeria]
        case .Ukrainian:
            [.Ukraine]
        case .Romanian:
            [.Romania]
        case .Dutch:
            [.Netherlands]
        case .Greek:
            [.Greece]
        case .Hungarian:
            [.Hungary]
        case .Azerbaijani:
            [.Azerbaijan]
        case .Hebrew:
            [.Israel]
        case .Uzbek:
            [.Uzbekistan]
        case .Catalan:
            [.Spain]
        case .Khmer:
            [.Cambodia]
        case .Tajik:
            [.Tajikistan]
        case .Somali:
            [.Somalia]
        case .Czech:
            [.Czech_Republic]
        case .Swedish:
            [.Sweden]
        case .Serbian:
            [.Serbia]
        case .Danish:
            [.Denmark]
        case .Finnish:
            [.Finland]
        case .Slovak:
            [.Slovakia]
        case .Norwegian:
            [.Norway]
        case .Slovenian:
            [.Slovenia]
        case .Croatian:
            [.Croatia]
        case .Lithuanian:
            [.Lithuania]
        case .Latvian:
            [.Latvia]
        case .Ewe:
            [.Togo]
        case .Afrikaans:
            [.South_Africa]
        case .Bulgarian:
            [.Bulgaria]
        case .Estonian:
            [.Estonia]
        case .Macedonian:
            [.Macedonia]
        case .Albanian:
            [.Albania]
        case .Icelandic:
            [.Iceland]
        case .Irish:
            [.Ireland]
        case .Maltese:
            [.Malta]
        case .Welsh:
            [.United_Kingdom]
        case .Scottish_Gaelic:
            [.United_Kingdom]
        case .Armenian:
            [.Armenia]
        case .Georgian:
            [.Georgia]
        }
    }
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

enum ResolvedLanguageCode {
    case custom(String)
    case common(CommonLanguageCode)
    var value: String? {
        switch self {
        case .custom(let string):
            guard !string.isEmpty else { return nil }
            return string
        case .common(let commonCode):
            return commonCode.rawValue
        }
    }
}

enum ResolvedScriptCode {
    case custom(String)
    case common(CommonScriptCode)
    var value: String? {
        switch self {
        case .custom(let string):
            guard !string.isEmpty else { return nil }
            return string
        case .common(let commonCode):
            return commonCode.rawValue
        }
    }
}

enum ResolvedRegionCode {
    case custom(String)
    case common(CommonRegionCode)
    var value: String? {
        switch self {
        case .custom(let string):
            guard !string.isEmpty else { return nil }
            return string
        case .common(let commonCode):
            return commonCode.rawValue
        }
    }
}

struct ResolvedBCP47Code {
    let language: ResolvedLanguageCode
    let script: ResolvedScriptCode?
    let region: ResolvedRegionCode?

    fileprivate init(language: ResolvedLanguageCode, script: ResolvedScriptCode?, region: ResolvedRegionCode?) {
        self.language = language
        self.script = script
        self.region = region
    }

    var value: String? {
        guard let language = language.value else { return nil }

        return [
            language,
            script?.value,
            region?.value,
        ].compactMap({ $0 }).joined(separator: "-")
    }

    var isCommonCombination: Bool {
        guard case .common(let commonLanguage) = language else { return false }
        switch (script, region) {
        case (.some(.common(let commonScript)), .none) where
            commonLanguage.relevantScripts.contains(commonScript):
            return true
        case (.none, .some(.common(let commonRegion))) where
            commonLanguage.relevantRegions.contains(commonRegion):
            return true
        case (.some(.common(let commonScript)), .some(.common(let commonRegion))) where
            commonLanguage.relevantScripts.contains(commonScript) &&
            commonLanguage.relevantRegions.contains(commonRegion):
            return true
        default:
            return false
        }
    }
}

struct BCP47CodeGenerator {
    var language: String
    var script: String
    var region: String

    var commonLanguage: CommonLanguageCode? {
        CommonLanguageCode(rawValue: language)
    }

    var customLanguage: String? {
        guard !language.isEmpty, commonLanguage == nil else { return nil }
        return language
    }

    var resolvedLanguage: ResolvedLanguageCode? {
        commonLanguage.map(ResolvedLanguageCode.common) ?? customLanguage.map(ResolvedLanguageCode.custom)
    }

    var commonScript: CommonScriptCode? {
        CommonScriptCode(rawValue: script)
    }

    var customScript: String? {
        guard !script.isEmpty, commonScript == nil else { return nil }
        return script
    }

    var resolvedScript: ResolvedScriptCode? {
        commonScript.map(ResolvedScriptCode.common) ?? customScript.map(ResolvedScriptCode.custom)
    }

    var commonRegion: CommonRegionCode? {
        CommonRegionCode(rawValue: region)
    }

    var customRegion: String? {
        guard !region.isEmpty, commonRegion == nil else { return nil }
        return region
    }

    var resolvedRegion: ResolvedRegionCode? {
        commonRegion.map(ResolvedRegionCode.common) ?? customRegion.map(ResolvedRegionCode.custom)
    }

    var resolved: ResolvedBCP47Code? {
        guard let resolvedLanguage else { return nil }
        return .init(
            language: resolvedLanguage,
            script: resolvedScript,
            region: resolvedRegion
        )
    }
}
