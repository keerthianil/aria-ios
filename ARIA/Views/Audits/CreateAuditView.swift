import SwiftUI
import SwiftData

struct CreateAuditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// When provided, the sheet edits this audit's metadata instead of creating a new one.
    var auditToEdit: Audit? = nil

    @State private var name = ""
    @State private var appName = ""
    @State private var platform: Platform = .iOS
    @State private var auditorName = ""

    private var isEditing: Bool { auditToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Audit Details") {
                    TextField("Audit name", text: $name, prompt: Text("e.g., Q2 Accessibility Review"))
                    TextField("App name", text: $appName, prompt: Text("e.g., Spotify iOS"))
                }

                Section("Platform") {
                    PlatformPicker(selection: $platform)
                }

                Section("Auditor") {
                    TextField("Your name", text: $auditorName, prompt: Text("e.g., Keerthi Anil"))
                }

                if !isEditing {
                    Section {
                        Text("You'll add screenshots after creating the audit.")
                            .font(Typography.callout)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Audit" : "New Audit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || appName.isEmpty)
                }
            }
            .onAppear {
                if let audit = auditToEdit {
                    name = audit.name
                    appName = audit.appName
                    platform = audit.platform
                    auditorName = audit.auditorName
                }
            }
        }
    }

    private func save() {
        if let audit = auditToEdit {
            audit.name = name
            audit.appName = appName
            audit.platform = platform
            audit.auditorName = auditorName
            audit.touch()
        } else {
            let audit = Audit(name: name, appName: appName, platform: platform, auditorName: auditorName)
            modelContext.insert(audit)
        }
        dismiss()
    }
}

/// Segmented-style platform picker that actually shows each platform's icon
/// (the built-in `.segmented` picker style drops SF Symbols).
struct PlatformPicker: View {
    @Binding var selection: Platform

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(Platform.allCases) { platform in
                let isOn = selection == platform
                Button {
                    selection = platform
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: platform.iconName)
                            .font(.title3)
                        Text(platform.displayName)
                            .font(Typography.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(isOn ? ColorTokens.brandPrimary.opacity(0.15) : ColorTokens.backgroundSecondary)
                    .foregroundStyle(isOn ? ColorTokens.brandPrimary : ColorTokens.textSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isOn ? ColorTokens.brandPrimary : .clear, lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(platform.displayName)
                .accessibilityAddTraits(isOn ? [.isSelected, .isButton] : .isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Target platform")
    }
}
