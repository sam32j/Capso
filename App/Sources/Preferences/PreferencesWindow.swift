// App/Sources/Preferences/PreferencesWindow.swift
import AppKit
import SwiftUI
import SharedKit

@MainActor
final class PreferencesWindow {
    private var window: NSWindow?
    private let settings: AppSettings
    private let permissionManager: PermissionManager
    private let updateManager: UpdateManager?

    init(settings: AppSettings, permissionManager: PermissionManager, updateManager: UpdateManager? = nil) {
        self.settings = settings
        self.permissionManager = permissionManager
        self.updateManager = updateManager
    }

    func show(tab: PreferencesTab? = nil) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            // Navigate to requested tab if window already exists.
            // Use a dedicated notification name (NOT .openScreenshotSettings)
            // to avoid recursing back through AppDelegate's observer.
            if let tab {
                NotificationCenter.default.post(name: .preferencesSwitchTab, object: tab)
            }
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "Capso Settings")
        window.minSize = NSSize(width: 680, height: 480)
        window.isReleasedWhenClosed = false
        window.center()
        let viewModel = PreferencesViewModel(settings: settings, permissionManager: permissionManager)
        let hostingController = NSHostingController(
            rootView: PreferencesView(viewModel: viewModel, updateManager: updateManager, initialTab: tab)
        )
        window.contentViewController = hostingController

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
