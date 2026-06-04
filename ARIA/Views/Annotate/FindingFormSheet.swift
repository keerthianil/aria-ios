import SwiftUI

struct FindingFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var finding: Finding
    @State private var showCriterionPicker = false

    private var selectedCriterion: WCAGCriterion? {
        WCAGDatabase.criteria.first { $0.id == finding.wcagCriterionID }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("WCAG Criterion") {
                    Button {
                        showCriterionPicker = true
                    } label: {
                        HStack {
                            if let criterion = selectedCriterion {
                                VStack(alignment: .leading) {
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
                    .foregroundStyle(ColorTokens.textPrimary)
                }

                Section("Severity") {
                    Picker("Severity", selection: $finding.severity) {
                        ForEach(Severity.allCases) { sev in
                            HStack {
                                Circle()
                                    .fill(severityColor(sev))
                                    .frame(width: 8, height: 8)
                                Text(sev.displayName)
                            }
                            .tag(sev)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("What's wrong?") {
                    TextField("Describe the violation", text: $finding.findingDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("How to fix it") {
                    TextField("Recommendation", text: $finding.recommendation, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Finding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
            .sheet(isPresented: $showCriterionPicker) {
                CriterionPickerView(selectedID: $finding.wcagCriterionID)
            }
        }
    }

    private func severityColor(_ severity: Severity) -> Color {
        switch severity {
        case .critical: ColorTokens.severityCritical
        case .major: ColorTokens.severityMajor
        case .minor: ColorTokens.severityMinor
        case .advisory: ColorTokens.severityAdvisory
        }
    }
}
