import SwiftUI

struct SettingSearchPreferenceKey: PreferenceKey {
    static let defaultValue: [SettingSearchItem] = []

    static func reduce(value: inout [SettingSearchItem], nextValue: () -> [SettingSearchItem]) {
        value.append(contentsOf: nextValue())
    }
}

private struct SettingSearchTabKey: EnvironmentKey {
    static let defaultValue: PreferencesTab? = nil
}

private struct SettingSearchSectionKey: EnvironmentKey {
    static let defaultValue: LocalizedStringResource? = nil
}

private struct ActivePreferencesTabKey: EnvironmentKey {
    static let defaultValue = true
}

private struct HighlightedSettingIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var settingSearchTab: PreferencesTab? {
        get { self[SettingSearchTabKey.self] }
        set { self[SettingSearchTabKey.self] = newValue }
    }

    var settingSearchSection: LocalizedStringResource? {
        get { self[SettingSearchSectionKey.self] }
        set { self[SettingSearchSectionKey.self] = newValue }
    }

    var isActivePreferencesTab: Bool {
        get { self[ActivePreferencesTabKey.self] }
        set { self[ActivePreferencesTabKey.self] = newValue }
    }

    var highlightedSettingId: String? {
        get { self[HighlightedSettingIDKey.self] }
        set { self[HighlightedSettingIDKey.self] = newValue }
    }
}

extension View {
    func settingSearchTab(_ tab: PreferencesTab) -> some View {
        environment(\.settingSearchTab, tab)
    }

    func searchableSetting(
        _ title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        id: String? = nil
    ) -> some View {
        modifier(SettingSearchRegistration(title: title, subtitle: subtitle, explicitID: id))
    }
}

private struct SettingSearchRegistration: ViewModifier {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let explicitID: String?
    @Environment(\.settingSearchTab) private var tab
    @Environment(\.settingSearchSection) private var section
    @Environment(\.locale) private var locale

    private var item: SettingSearchItem? {
        guard let tab else { return nil }
        return SettingSearchItem(
            id: "\(tab.rawValue):\(section?.key ?? ""):\(explicitID ?? title.key)",
            tab: tab,
            title: title.localized(for: locale),
            section: section?.localized(for: locale) ?? "",
            subtitle: subtitle?.localized(for: locale),
            tabTitle: tab.localizedTitle.localized(for: locale)
        )
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if let item {
            content
                .modifier(SettingSearchHighlight(id: item.id))
                .transformPreference(SettingSearchPreferenceKey.self) { items in
                    items.append(item)
                }
        } else {
            content
        }
    }
}

private struct SettingSearchHighlight: ViewModifier {
    let id: String
    @Environment(\.highlightedSettingId) private var highlightedID
    @State private var isHighlighted = false

    func body(content: Content) -> some View {
        content
            .id(id)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(isHighlighted ? 0.18 : 0))
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(isHighlighted ? 0.8 : 0), lineWidth: 2)
                    .allowsHitTesting(false)
            }
            .animation(.easeInOut(duration: 0.25), value: isHighlighted)
            .task(id: highlightedID) {
                isHighlighted = highlightedID == id
                guard isHighlighted else { return }
                do {
                    try await Task.sleep(for: .seconds(2.5))
                } catch {
                    return
                }
                isHighlighted = false
            }
    }
}
