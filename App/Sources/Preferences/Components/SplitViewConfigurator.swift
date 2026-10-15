import AppKit
import SwiftUI

/// Disables collapsing the sidebar on mouse drag and enforces the minimum sidebar width
struct SplitViewConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async { [weak view] in
            guard let view else { return }
            configureSplitView(from: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { [weak nsView] in
            guard let nsView else { return }
            configureSplitView(from: nsView)
        }
    }

    private func configureSplitView(from view: NSView) {
        guard let window = view.window else { return }
        
        // Find NSSplitViewController in the window's controller hierarchy
        if let splitViewController = findSplitViewController(in: window.contentViewController) {
            if let sidebarItem = splitViewController.splitViewItems.first {
                sidebarItem.canCollapse = false
                sidebarItem.minimumThickness = 190
                sidebarItem.maximumThickness = 190
            }
        }
    }

    private func findSplitViewController(in vc: NSViewController?) -> NSSplitViewController? {
        guard let vc else { return nil }
        if let svc = vc as? NSSplitViewController { return svc }
        for child in vc.children {
            if let svc = findSplitViewController(in: child) { return svc }
        }
        return nil
    }
}
