import SwiftUI
import SwiftData

@main
struct ARIAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Audit.self, AuditScreen.self, Finding.self])
    }
}
