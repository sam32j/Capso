// App/Sources/Preferences/Tabs/ShortcutSettingsView.swift
import SwiftUI
import AppKit
import KeyboardShortcuts
import SharedKit

extension KeyboardShortcuts.Name {
    static let captureAllInOne = Self("captureAllInOne")
    static let captureArea = Self("captureArea", default: .init(.one, modifiers: [.option, .shift]))
    static let captureFullscreen = Self("captureFullscreen", default: .init(.two, modifiers: [.option, .shift]))
    static let captureWindow = Self("captureWindow", default: .init(.three, modifiers: [.option, .shift]))
    static let captureText = Self("captureText", default: .init(.four, modifiers: [.option, .shift]))
    /// Keep the existing storage key so current users retain their recording shortcut.
    static let recordScreen = Self("recordScreen", default: .init(.five, modifiers: [.option, .shift]))
    /// Opt-in to avoid adding another default global shortcut.
    static let recordFullscreen = Self("recordFullscreen")
    static let captureScrolling = Self("captureScrolling", default: .init(.six, modifiers: [.option, .shift]))
    static let captureAreaToClipboard = Self("captureAreaToClipboard", default: .init(.seven, modifiers: [.option, .shift]))
    static let captureAreaAndShare = Self("captureAreaAndShare", default: .init(.zero, modifiers: [.option, .shift]))
    static let captureAreaAndAnnotate = Self("captureAreaAndAnnotate", default: .init(.eight, modifiers: [.option, .shift]))
    static let captureAreaAndPin = Self("captureAreaAndPin")
    static let pinFromClipboard = Self("pinFromClipboard")
    static let editClipboardImage = Self("editClipboardImage")
    static let screenshotHistory = Self("screenshotHistory", default: .init(.nine, modifiers: [.option, .shift]))
    static let captureAndTranslate = Self("captureAndTranslate", default: .init(.t, modifiers: [.option, .shift]))
    static let translateSelectedText = Self("translateSelectedText", default: .init(.y, modifiers: [.option, .shift]))
    static let translateTypedText = Self("translateTypedText")
    /// No default binding — opt-in. Self-Timer is discoverable from the
    /// menu bar; shipping a default risks colliding with whatever the user
    /// has already bound in macOS or third-party apps.
    static let selfTimerCapture = Self("selfTimerCapture")
    /// Replays the last capture (area / window / fullscreen) without showing
    /// the selection overlay. Unbound by default — user must assign a key.
    static let captureLastArea = Self("captureLastArea")
    /// Unbound by default.
    static let togglePins = Self("togglePins")

    static let allCapso: [Self] = [
        .captureAllInOne, .captureArea, .captureFullscreen, .captureWindow, .captureText, .recordScreen,
        .recordFullscreen, .captureScrolling, .captureAreaToClipboard, .captureAreaAndShare,
        .captureAreaAndAnnotate, .captureAreaAndPin, .pinFromClipboard, .editClipboardImage, .screenshotHistory,
        .captureAndTranslate, .translateSelectedText, .translateTypedText, .selfTimerCapture, .captureLastArea, .togglePins,
    ]
}

struct ShortcutSettingsView: View {
    @Bindable var viewModel: PreferencesViewModel
    private struct ContextualShortcut: Identifiable {
        let id: String
        let scope: LocalizedStringResource
        let action: LocalizedStringResource
        /// One or more keycaps to render for this action. `.copy` in
        /// All-in-One lists all three bindings (⌘C, Return, ⌘⇧C) so users
        /// discover Return and ⌘⇧C alongside ⌘C — see issue #237.
        let shortcuts: [String]
    }

    private let contextualShortcuts: [ContextualShortcut] = [
        ContextualShortcut(id: "all-in-one-copy", scope: "All-in-One", action: "Copy selected area", shortcuts: ["⌘C", "⏎", "⌘⇧C"]),
        ContextualShortcut(id: "all-in-one-save", scope: "All-in-One", action: "Save selected area", shortcuts: ["⌘S"]),
        ContextualShortcut(id: "all-in-one-pin", scope: "All-in-One", action: "Pin selected area", shortcuts: ["⌘P"]),
        ContextualShortcut(id: "all-in-one-cancel", scope: "All-in-One", action: "Cancel", shortcuts: ["Esc"]),
        ContextualShortcut(id: "window-multi-select", scope: "Window Capture", action: "Select multiple windows", shortcuts: ["⇧ + click"]),
        ContextualShortcut(id: "window-multi-confirm", scope: "Window Capture", action: "Capture selected windows", shortcuts: ["Release ⇧"]),
        ContextualShortcut(id: "quick-access-copy", scope: "Quick Access", action: "Copy", shortcuts: ["⌘C"]),
        ContextualShortcut(id: "quick-access-save", scope: "Quick Access", action: "Save", shortcuts: ["⌘S"]),
        ContextualShortcut(id: "quick-access-annotate", scope: "Quick Access", action: "Annotate", shortcuts: ["⌘E"]),
        ContextualShortcut(id: "quick-access-pin", scope: "Quick Access", action: "Pin", shortcuts: ["⌘P"])
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Shortcuts")
                .font(.system(size: 20, weight: .bold))

            // Info banner
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("Click a customizable shortcut to record a new combination. Press Esc to cancel or Delete to remove. Contextual shortcuts are fixed and work only while that panel is active.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
            )

            SystemScreenshotShortcutsCard()

            SettingGroup(title: "Customizable Shortcuts") {
                SettingCard {
                    shortcutRow("All-in-One", name: .captureAllInOne)
                    shortcutRow("Capture Area", name: .captureArea, showDivider: true)
                    shortcutRow("Capture Fullscreen", name: .captureFullscreen, showDivider: true)
                    shortcutRow("Capture Window", name: .captureWindow, showDivider: true)
                    shortcutRow("Capture Text (OCR)", name: .captureText, showDivider: true)
                    shortcutRow("Scrolling Capture", name: .captureScrolling, showDivider: true)
                    shortcutRow("Self-Timer", name: .selfTimerCapture, showDivider: true)
                    shortcutRow("Capture Area to Clipboard", name: .captureAreaToClipboard, showDivider: true)
                    shortcutRow("Capture and Share to Cloud", name: .captureAreaAndShare, showDivider: true)
                    shortcutRow("Capture Area & Annotate", name: .captureAreaAndAnnotate, showDivider: true)
                    shortcutRow("Capture Area & Pin", name: .captureAreaAndPin, showDivider: true)
                    shortcutRow(
                        "Pin from Clipboard",
                        name: .pinFromClipboard,
                        showDivider: true,
                        help: "Float copied images, text, colors, or files above other windows"
                    )
                    shortcutRow(
                        "Edit Clipboard Image",
                        name: .editClipboardImage,
                        showDivider: true,
                        help: "Open the image currently copied to the clipboard in Annotate"
                    )
                    shortcutRow("Hide / Show All Pins", name: .togglePins, showDivider: true)
                    shortcutRow("Capture & Translate", name: .captureAndTranslate, showDivider: true)
                    shortcutRow("Translate Selected Text", name: .translateSelectedText, showDivider: true)
                    shortcutRow("Translate Typed Text", name: .translateTypedText, showDivider: true)
                    shortcutRow("Capture Previous Area", name: .captureLastArea, showDivider: true)
                    shortcutRow("Record Area", name: .recordScreen, showDivider: true)
                    shortcutRow("Record Full Screen", name: .recordFullscreen, showDivider: true)
                    shortcutRow("Screenshot History", name: .screenshotHistory, showDivider: true)
                }
            }

            SettingGroup(title: "Contextual Shortcuts") {
                SettingCard {
                    centerLockRow
                    ForEach(Array(contextualShortcuts.enumerated()), id: \.element.id) { _, item in
                        contextualShortcutRow(item, showDivider: true)
                    }
                }
            }
        }
    }

    private var centerLockRow: some View {
        SettingRow(
            label: "Center 1:1 from click",
            sublabel: "Selection",
            showDivider: false
        ) {
            HStack(spacing: 6) {
                ShortcutKeycap(text: "⇧")
                Text("+")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                SquareCenterLockKeyRecorder(shortcut: $viewModel.squareCenterLockShortcut)
            }
        }
        .help("Hold Shift for 1:1, then this extra key to grow from the click as the center. Shift cannot be changed.")
    }

    @ViewBuilder
    private func shortcutRow(
        _ label: LocalizedStringResource,
        name: KeyboardShortcuts.Name,
        showDivider: Bool = false,
        help: LocalizedStringKey? = nil
    ) -> some View {
        let row = SettingRow(label: label, showDivider: showDivider, searchID: name.rawValue) {
            KeyboardShortcuts.Recorder(for: name)
                .controlSize(.small)
        }

        if let help {
            row.help(help)
        } else {
            row
        }
    }

    private func contextualShortcutRow(_ item: ContextualShortcut, showDivider: Bool = false) -> some View {
        SettingRow(label: item.action, sublabel: item.scope, showDivider: showDivider, searchID: item.id) {
            HStack(spacing: 6) {
                ForEach(Array(item.shortcuts.enumerated()), id: \.offset) { _, shortcut in
                    ShortcutKeycap(text: shortcut)
                }
            }
        }
    }
}
