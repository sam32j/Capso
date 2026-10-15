import AppKit
import SharedKit
import SwiftUI
import XCTest
@testable import Capso

@MainActor
final class SettingsSearchTests: XCTestCase {
    func testRowsPublishTheDisplayedGermanAndChineseTitles() {
        for (language, expected) in [("de", "Bei Anmeldung starten"), ("zh-Hans", "登录时启动")] {
            let items = collect(
                SettingGroup(title: "Startup") {
                    SettingRow(label: "Launch at Login") { EmptyView() }
                }
                .settingSearchTab(.general)
                .environment(\.locale, Locale(identifier: language))
            )
            XCTAssertTrue(items.contains { $0.title == expected })
            XCTAssertTrue(SettingSearchIndex.results(for: expected, in: items).contains { $0.title == expected })
        }
    }

    func testDestinationsStayStableAcrossLanguages() throws {
        func destination(language: String, title: String) throws -> String {
            let items = collect(
                SettingGroup(title: "Startup") {
                    SettingRow(label: "Launch at Login") { EmptyView() }
                }
                .settingSearchTab(.general)
                .environment(\.locale, Locale(identifier: language))
            )
            return try XCTUnwrap(items.first { $0.title == title }).id
        }
        XCTAssertEqual(
            try destination(language: "en", title: "Launch at Login"),
            try destination(language: "de", title: "Bei Anmeldung starten")
        )
    }

    func testEndpointAndModelHaveSeparateDestinations() throws {
        let items = collect(
            SettingGroup(title: "Translation") {
                SettingRow(label: "Endpoint") { EmptyView() }
                SettingRow(label: "Model") { EmptyView() }
            }
            .settingSearchTab(.ocr)
            .environment(\.locale, Locale(identifier: "en"))
        )
        let endpoint = try XCTUnwrap(items.first { $0.title == "Endpoint" })
        let model = try XCTUnwrap(items.first { $0.title == "Model" })
        XCTAssertNotEqual(endpoint.id, model.id)
        XCTAssertEqual(SettingSearchIndex.results(for: "Model", in: items).map(\.id), [model.id])
    }

    func testSameLabelOnDifferentTabsHasDifferentDestinations() {
        let items = collect(
            VStack {
                SettingRow(label: "Show Cursor") { EmptyView() }.settingSearchTab(.screenshots)
                SettingRow(label: "Show Cursor") { EmptyView() }.settingSearchTab(.recording)
            }
        )
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(Set(items.map(\.id)).count, 2)
        XCTAssertEqual(Set(items.map(\.tab)), [.screenshots, .recording])
    }

    func testConditionalControlsRegisterOnlyWhileAvailable() {
        for isAvailable in [false, true] {
            let items = collect(
                VStack {
                    SettingRow(label: "Provider") { EmptyView() }
                    if isAvailable {
                        SettingRow(label: "Model") { EmptyView() }
                    }
                }
                .settingSearchTab(.ocr)
                .environment(\.locale, Locale(identifier: "en"))
            )
            XCTAssertEqual(items.contains { $0.title == "Model" }, isAvailable)
        }
    }

    func testInitialSearchIncludesUnvisitedTabsAndActualShortcutRows() throws {
        let suiteName = "SettingsSearchTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let model = PreferencesViewModel(settings: AppSettings(defaults: defaults), permissionManager: PermissionManager())
        let items = collect(
            PreferencesView(viewModel: model, updateManager: nil, initialTab: .general)
                .environment(\.locale, Locale(identifier: "en"))
        )
        XCTAssertEqual(Set(items.map(\.tab)), Set(PreferencesTab.allCases))
        for title in ["Launch at Login", "Show Preview", "Export Quality", "Capture Area", "Record Area", "All-in-One"] {
            XCTAssertTrue(items.contains { $0.title == title }, "Missing searchable row: \(title)")
        }
        XCTAssertEqual(items.count, Set(items.map(\.id)).count, "Search destinations must be unique")
        XCTAssertFalse(items.contains { $0.subtitle?.contains("⇧⌘2") == true })
        XCTAssertFalse(items.contains { $0.title == "Dim Screen While Recording" })
        XCTAssertFalse(items.contains { $0.title == "Default Recording Format" })
    }

    func testMatchingHandlesWordsCaseAndDiacritics() {
        let item = SettingSearchItem(id: "image", tab: .screenshots, title: "Écran Capture", section: "Images", subtitle: "Clipboard")
        XCTAssertEqual(SettingSearchIndex.results(for: "  ECRAN clipboard  ", in: [item]), [item])
        XCTAssertTrue(SettingSearchIndex.results(for: "écran missing", in: [item]).isEmpty)
        XCTAssertTrue(SettingSearchIndex.results(for: "  \n", in: [item]).isEmpty)
    }

    private func collect<Content: View>(_ content: Content) -> [SettingSearchItem] {
        let capture = SearchPreferenceCapture()
        let host = NSHostingView(rootView: content.onPreferenceChange(SettingSearchPreferenceKey.self) { items in
            Task { @MainActor in capture.items = items }
        })
        host.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        host.layoutSubtreeIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        withExtendedLifetime(host) {}
        return capture.items
    }
}

@MainActor
private final class SearchPreferenceCapture {
    var items: [SettingSearchItem] = []
}
