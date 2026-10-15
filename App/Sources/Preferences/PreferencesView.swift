import Combine
import SwiftUI

enum PreferencesSidebarItem: Hashable {
    case tab(PreferencesTab)
    case searchResult(SettingSearchItem)
}

struct PreferencesView: View {
    @State private var selectedSidebarItem: PreferencesSidebarItem?
    @State private var activeTab: PreferencesTab
    @State private var searchText = ""
    @State private var searchItems: [SettingSearchItem] = []
    @State private var highlightedItemID: String?
    let viewModel: PreferencesViewModel
    let updateManager: UpdateManager?

    init(viewModel: PreferencesViewModel, updateManager: UpdateManager?, initialTab: PreferencesTab? = nil) {
        self.viewModel = viewModel
        self.updateManager = updateManager
        let tab = initialTab ?? .general
        _activeTab = State(initialValue: tab)
        _selectedSidebarItem = State(initialValue: .tab(tab))
    }

    var body: some View {
        NavigationSplitView {
            PreferencesSidebar(
                selection: $selectedSidebarItem,
                searchText: $searchText,
                items: SettingSearchIndex.results(for: searchText, in: searchItems)
            )
        } detail: {
            // Keep metadata from unvisited tabs in the same preference tree.
            // Inactive rows omit their controls, including shortcut recorders.
            ZStack(alignment: .topLeading) {
                ForEach(PreferencesTab.allCases) { tab in
                    tabPage(tab)
                        .settingSearchTab(tab)
                        .environment(\.isActivePreferencesTab, tab == activeTab)
                        .environment(\.highlightedSettingId, tab == activeTab ? highlightedItemID : nil)
                        .opacity(tab == activeTab ? 1 : 0)
                        .allowsHitTesting(tab == activeTab)
                        .disabled(tab != activeTab)
                        .accessibilityHidden(tab != activeTab)
                        .zIndex(tab == activeTab ? 1 : 0)
                }
            }
            .navigationTitle(activeTab.displayTitle)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 700, idealWidth: 800, minHeight: 480, idealHeight: 560)
        .background { SplitViewConfigurator() }
        .onPreferenceChange(SettingSearchPreferenceKey.self) { items in
            Task { @MainActor in searchItems = items }
        }
        .onChange(of: selectedSidebarItem) { _, selection in
            switch selection {
            case .searchResult(let item):
                activeTab = item.tab
                highlightedItemID = item.id
            case .tab(let tab):
                activeTab = tab
                highlightedItemID = nil
            case nil:
                break
            }
        }
        .onChange(of: searchText) { _, text in
            selectedSidebarItem = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .tab(activeTab) : nil
            highlightedItemID = nil
        }
        .onChange(of: searchItems) { _, items in
            if let highlightedItemID, !items.contains(where: { $0.id == highlightedItemID }) {
                self.highlightedItemID = nil
                selectedSidebarItem = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openScreenshotSettings)) { notification in
            navigate(to: (notification.object as? PreferencesTab) ?? .screenshots)
        }
        .onReceive(NotificationCenter.default.publisher(for: .preferencesSwitchTab)) { notification in
            if let tab = notification.object as? PreferencesTab {
                navigate(to: tab)
            }
        }
    }

    private func navigate(to tab: PreferencesTab) {
        searchText = ""
        activeTab = tab
        selectedSidebarItem = .tab(tab)
        highlightedItemID = nil
    }

    private func tabPage(_ tab: PreferencesTab) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                tabView(for: tab)
                    .searchableSetting(tab.localizedTitle, id: "tab")
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .task(id: highlightedItemID) {
                guard tab == activeTab, let highlightedItemID else { return }
                await Task.yield()
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(highlightedItemID, anchor: .center)
                }
            }
        }
    }

    @ViewBuilder
    private func tabView(for tab: PreferencesTab) -> some View {
        switch tab {
        case .general:
            GeneralSettingsView(viewModel: viewModel, updateManager: updateManager)
        case .permissions:
            PermissionSettingsView(viewModel: viewModel)
        case .screenshots:
            ScreenshotSettingsView(viewModel: viewModel)
        case .recording:
            RecordingSettingsView(viewModel: viewModel)
        case .quickAccess:
            QuickAccessSettingsView(viewModel: viewModel)
        case .cloudShare:
            CloudShareSettingsView(viewModel: viewModel)
        case .export:
            ExportSettingsView(viewModel: viewModel)
        case .ocr:
            TextAndTranslationSettingsView(viewModel: viewModel)
        case .shortcuts:
            ShortcutSettingsView(viewModel: viewModel)
        }
    }
}
