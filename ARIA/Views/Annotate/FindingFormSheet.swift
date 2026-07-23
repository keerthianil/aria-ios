import SwiftUI

struct FindingFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var finding: Finding
    @State private var showCriterionPicker = false
    @State private var showDeleteConfirm = false
    var onDelete: (() -> Void)?

    private var selectedCriterion: WCAGCriterion? {
        WCAGDatabase.criteria.first { $0.id == finding.wcagCriterionID }
    }

    @ViewBuilder
    private var criterionLabel: some View {
        HStack {
            if let criterion = selectedCriterion {
                VStack(alignment: .leading, spacing: 2) {
                    Text(criterion.fullTitle)
                        .font(Typography.headline)
                    Text(criterion.description)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .lineLimit(2)
                }
            } else {
                Text("Select criterion")
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(ColorTokens.textTertiary)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("WCAG Criterion") {
                    Button {
                        showCriterionPicker = true
                    } label: {
                        criterionLabel
                    }
                    .foregroundStyle(ColorTokens.textPrimary)
                    .accessibilityLabel("WCAG criterion")
                    .accessibilityValue(selectedCriterion?.fullTitle ?? "None selected")
                    .accessibilityHint("Opens the WCAG criterion picker")
                }

                Section {
                    Picker("Severity", selection: $finding.severity) {
                        ForEach(Severity.allCases) { sev in
                            HStack(spacing: 8) {
                                Image(systemName: sev.iconName)
                                    .foregroundStyle(sev.color)
                                Text(sev.displayName)
                            }
                            .tag(sev)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Severity")
                } footer: {
                    Text(finding.severity.guidance)
                }

                Section("What's wrong?") {
                    TextField("Describe the violation", text: $finding.findingDescription, axis: .vertical)
                        .lineLimit(3...8)
                        .accessibilityLabel("Violation description")
                }

                Section("How to fix it") {
                    TextField("Recommendation", text: $finding.recommendation, axis: .vertical)
                        .lineLimit(3...8)
                        .accessibilityLabel("Fix recommendation")
                }

                Section {
                    Toggle(isOn: $finding.isFixed) {
                        Label("Marked as fixed", systemImage: finding.isFixed ? "checkmark.circle.fill" : "circle")
                    }
                    .tint(ColorTokens.pass)
                }

                if onDelete != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Finding", systemImage: "trash")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Finding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showCriterionPicker) {
                CriterionPickerView(selectedID: $finding.wcagCriterionID)
            }
            .confirmationDialog("Delete this finding?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Finding", role: .destructive) { onDelete?() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}
