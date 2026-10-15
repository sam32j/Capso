import SwiftUI
import AppKit
import KeyboardShortcuts
import SharedKit

struct SquareCenterLockKeyRecorder: View {
    @Binding var shortcut: SquareCenterLockShortcut
    @State private var isRecording = false

    var body: some View {
        Button {
            isRecording.toggle()
        } label: {
            Text(isRecording ? "…" : shortcut.displayCharacter)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(isRecording ? Color.accentColor : Color.secondary)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(
                    Color.primary.opacity(isRecording ? 0.12 : 0.08),
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            isRecording ? Color.accentColor : Color.primary.opacity(0.10),
                            lineWidth: isRecording ? 1.5 : 0.5
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Extra key for centered 1:1")
        .accessibilityValue(shortcut.displayCharacter)
        .help("Click to record a different extra key")
        .background {
            if isRecording {
                CenterLockKeyCapture { event in
                    if event.keyCode == 53 {
                        isRecording = false
                        return
                    }
                    if let recorded = SquareCenterLockShortcut(event: event) {
                        shortcut = recorded
                        isRecording = false
                    }
                }
            }
        }
    }
}

/// Local key-down monitor used only while the extra-key recorder is listening.
private struct CenterLockKeyCapture: NSViewRepresentable {
    var onKeyDown: (NSEvent) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onKeyDown: onKeyDown)
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.install()
        return NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onKeyDown = onKeyDown
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator {
        var onKeyDown: (NSEvent) -> Void
        private var monitor: Any?

        init(onKeyDown: @escaping (NSEvent) -> Void) {
            self.onKeyDown = onKeyDown
        }

        func install() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.onKeyDown(event)
                return nil
            }
        }

        func uninstall() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }
    }
}

struct ShortcutKeycap: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.primary.opacity(0.10), lineWidth: 0.5)
            )
    }
}

/// Helps hand ⇧⌘3 / ⇧⌘4 / ⇧⌘5 over from the macOS screenshot tool to Capso.
struct SystemScreenshotShortcutsCard: View {
    @State private var systemShortcutsOn = SystemScreenshotShortcuts.areEnabled
    @State private var capsoUsesAny = Self.capsoUsesAnySystemKey

    private static let assignments: [(KeyboardShortcuts.Name, KeyboardShortcuts.Key)] = [
        (.captureFullscreen, .three), (.captureArea, .four), (.captureAllInOne, .five),
    ]

    /// Once any Capso action uses one of these keys, the user has set them up themselves.
    private static var capsoUsesAnySystemKey: Bool {
        let systemKeys = assignments.map { KeyboardShortcuts.Shortcut($0.1, modifiers: [.command, .shift]) }
        return KeyboardShortcuts.Name.allCapso.contains { name in
            KeyboardShortcuts.getShortcut(for: name).map(systemKeys.contains) ?? false
        }
    }

    var body: some View {
        Group {
            if systemShortcutsOn {
                banner(
                    icon: "exclamationmark.triangle",
                    tint: .orange,
                    text: "macOS still uses ⇧⌘3, ⇧⌘4 and ⇧⌘5 for its own screenshots. To use them for Capso, turn off the shortcuts under Keyboard Shortcuts → Screenshots."
                ) {
                    Button("Open Keyboard Settings") { NSWorkspace.shared.open(SystemScreenshotShortcuts.settingsURL) }
                        .searchableSetting("Open Keyboard Settings")
                }
            } else if !capsoUsesAny {
                banner(
                    icon: "keyboard",
                    tint: .blue,
                    text: "The macOS screenshot shortcuts are off. Capso can take them over: ⇧⌘3 Capture Fullscreen, ⇧⌘4 Capture Area, ⇧⌘5 All-in-One."
                ) {
                    Button("Use ⇧⌘3 / ⇧⌘4 / ⇧⌘5") {
                        for (name, key) in Self.assignments {
                            KeyboardShortcuts.setShortcut(.init(key, modifiers: [.command, .shift]), for: name)
                        }
                        capsoUsesAny = true
                    }
                    .searchableSetting("Use ⇧⌘3 / ⇧⌘4 / ⇧⌘5")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            systemShortcutsOn = SystemScreenshotShortcuts.areEnabled
            capsoUsesAny = Self.capsoUsesAnySystemKey
        }
    }

    private func banner(icon: String, tint: Color, text: LocalizedStringKey, @ViewBuilder action: () -> some View) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                action()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.2), lineWidth: 0.5))
    }
}
