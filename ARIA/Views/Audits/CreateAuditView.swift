import SwiftUI
import SwiftData

struct CreateAuditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var appName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Audit Details") {
                    TextField("Audit name", text: $name, prompt: Text("e.g., Q2 Accessibility Review"))
                    TextField("App name", text: $appName, prompt: Text("e.g., Spotify iOS"))
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
                        let audit = Audit(name: name, appName: appName)
                        modelContext.insert(audit)
                        dismiss()
                    }
                    .bold()
                    .disabled(name.isEmpty || appName.isEmpty)
                }
            }
        }
    }
}
