import SwiftUI

enum PreferencesTab: String, CaseIterable, Identifiable, Sendable {
    case general
    case permissions
    case screenshots
    case recording
    case quickAccess
    case cloudShare
    case export
    case ocr
    case shortcuts

    var id: String { rawValue }

    var title: LocalizedStringKey { LocalizedStringKey(displayTitle) }

    var displayTitle: String { String(localized: localizedTitle) }

    var localizedTitle: LocalizedStringResource {
        switch self {
        case .general: "General"
        case .permissions: "Permissions"
        case .screenshots: "Screenshots"
        case .recording: "Recording"
        case .quickAccess: "Quick Access"
        case .cloudShare: "Cloud Share"
        case .export: "Export"
        case .ocr: "Text & Translation"
        case .shortcuts: "Shortcuts"
        }
    }

    var icon: String {
        switch self {
        case .general: "gearshape"
        case .permissions: "lock.shield"
        case .screenshots: "camera"
        case .recording: "record.circle"
        case .quickAccess: "bolt"
        case .cloudShare: "icloud"
        case .export: "folder"
        case .ocr: "text.viewfinder"
        case .shortcuts: "keyboard"
        }
    }

    var badgeColor: Color {
        switch self {
        case .general: .gray
        case .permissions: .blue
        case .screenshots: .indigo
        case .recording: .red
        case .quickAccess: .orange
        case .cloudShare: .cyan
        case .export: .teal
        case .ocr: .green
        case .shortcuts: .purple
        }
    }
}
