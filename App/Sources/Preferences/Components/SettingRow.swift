import SwiftUI

struct SettingRow<Control: View>: View {
    let label: LocalizedStringResource
    var sublabel: LocalizedStringResource? = nil
    var showDivider: Bool = false
    var searchID: String? = nil
    @ViewBuilder let control: Control
    @Environment(\.locale) private var locale
    @Environment(\.isActivePreferencesTab) private var isActiveTab

    var body: some View {
        VStack(spacing: 0) {
            if showDivider {
                Divider()
                    .padding(.leading, 14)
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label.localized(for: locale))
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                    if let sublabel {
                        Text(sublabel.localized(for: locale))
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                if isActiveTab {
                    control
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 40)
        }
        .searchableSetting(label, subtitle: sublabel, id: searchID)
    }
}
