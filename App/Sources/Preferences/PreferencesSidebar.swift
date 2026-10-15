import SwiftUI

struct PreferencesSidebar: View {
    @Binding var selection: PreferencesSidebarItem?
    @Binding var searchText: String
    let items: [SettingSearchItem]

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        List(selection: $selection) {
            if isSearching {
                ForEach(items) { item in
                    NavigationLink(value: PreferencesSidebarItem.searchResult(item)) {
                        HStack(spacing: 8) {
                            badge(for: item.tab, size: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(2)
                                Text(item.breadcrumb)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            } else {
                ForEach(PreferencesTab.allCases) { tab in
                    NavigationLink(value: PreferencesSidebarItem.tab(tab)) {
                        HStack(spacing: 10) {
                            badge(for: tab, size: 22)
                            Text(tab.title)
                                .font(.system(size: 13))
                                .lineLimit(1)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 190, ideal: 190, max: 190)
        .searchable(text: $searchText, placement: .sidebar, prompt: Text("Search"))
        .toolbar(removing: .sidebarToggle)
        .overlay {
            if isSearching && items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 34))
                        .foregroundStyle(.tertiary)
                    Text("No results")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Check the spelling or try a new search.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            }
        }
    }

    private func badge(for tab: PreferencesTab, size: CGFloat) -> some View {
        Image(systemName: tab.icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(tab.badgeColor.gradient, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
