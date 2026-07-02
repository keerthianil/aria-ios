import SwiftUI
import SwiftData

struct CreateAuditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var appName = ""
    @State private var platform: Platform = .iOS
    @State private var auditorName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Audit Details") {
                    TextField("Audit name", text: $name, prompt: Text("e.g., Q2 Accessibility Review"))
                    TextField("App name", text: $appName, prompt: Text("e.g., Spotify iOS"))
                }

                Section("Platform") {
                    Picker("Platform", selection: $platform) {
                        ForEach(Platform.allCases) { p in
                            Label(p.displayName, systemImage: p.iconName)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .accessibilityLabel("Target platform")
                }

                Section("Auditor") {
                    TextField("Your name", text: $auditorName, prompt: Text("e.g., Keerthi Anil"))
                }

                Section {
                    Text("You'll add screenshots after creating the audit.")
                        .font(Typography.callout)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
            .navigationTitle("New Audit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let audit = Audit(name: name, appName: appName, platform: platform, auditorName: auditorName)
                        modelContext.insert(audit)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || appName.isEmpty)
                }
            }
        }
    }
}
