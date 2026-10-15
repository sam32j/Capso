import SwiftUI

struct SettingCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .preferencesGlassCard()
    }
}

struct SettingGroup<Content: View, Trailing: View>: View {
    let title: LocalizedStringResource
    let trailing: Trailing
    @ViewBuilder let content: Content
    @Environment(\.locale) private var locale

    init(
        title: LocalizedStringResource,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title.localized(for: locale))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .padding(.leading, 2)
                Spacer()
                trailing
            }
            content
                .environment(\.settingSearchSection, title)
        }
        .searchableSetting(title, id: "section-\(title.key)")
    }
}

extension SettingGroup where Trailing == EmptyView {
    init(title: LocalizedStringResource, @ViewBuilder content: () -> Content) {
        self.init(title: title, trailing: { EmptyView() }, content: content)
    }
}
