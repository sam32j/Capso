import Foundation

/// Metadata is emitted by the rendered settings, never copied into a second list.
struct SettingSearchItem: Hashable, Identifiable, Sendable {
    let id: String
    let tab: PreferencesTab
    let title: String
    let section: String
    var subtitle: String? = nil
    var tabTitle: String? = nil

    var breadcrumb: String {
        [tabTitle ?? tab.displayTitle, section]
            .filter { !$0.isEmpty }
            .joined(separator: " › ")
    }

    func matches(query: String) -> Bool {
        let words = query.split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return false }
        let text = [title, section, subtitle ?? "", tabTitle ?? tab.displayTitle]
            .joined(separator: " ")
        return words.allSatisfy { text.localizedStandardContains(String($0)) }
    }
}

enum SettingSearchIndex {
    static func results(for query: String, in items: [SettingSearchItem]) -> [SettingSearchItem] {
        items.filter { $0.matches(query: query) }
    }
}

extension LocalizedStringResource {
    func localized(for locale: Locale) -> String {
        var resource = self
        resource.locale = locale
        return String(localized: resource)
    }
}
