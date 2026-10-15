import SwiftUI
import ShareKit

enum CloudShareSettingsSupport {
    static func humanize(_ err: ShareError) -> String {
        switch err {
        case .notConfigured:
            return String(localized: "Configuration is incomplete. Re-run the wizard.")
        case .invalidCredentials:
            return String(localized: "The storage provider rejected the credentials. Verify the access key, secret, and bucket permissions.")
        case .invalidURLPrefix(let reason):
            return String(format: String(localized: "Invalid public URL prefix: %@"), reason)
        case .network(let underlying):
            return String(format: String(localized: "Network error: %@"), underlying)
        case .quotaExceeded:
            return String(localized: "Storage quota exceeded — free up space in your provider dashboard.")
        case .publicAccessUnreachable:
            return String(localized: "Upload worked, but the file isn't publicly reachable. Enable public access or use a public custom domain.")
        case .unknown(let s):
            return s
        }
    }
}

// Alert wrapper — `Identifiable` lets `.alert(item:)` re-trigger when a new
// result lands (binding-by-Bool would skip the second presentation if the
// user cancels then re-tests too quickly).
struct TestResultAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct CloudShareSetupPrompt: View {
    let onSetup: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "icloud")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(String(localized: "Cloud Share is not set up yet"))
                .font(.headline)
            Text(String(localized: "Connect your own cloud storage bucket to share captures with one click."))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(String(localized: "Set up Cloud Share")) {
                onSetup()
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .searchableSetting("Set up Cloud Share")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
