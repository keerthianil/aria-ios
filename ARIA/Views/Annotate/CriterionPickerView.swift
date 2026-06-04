import SwiftUI

struct CriterionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedID: String
    @State private var searchText = ""

    private var filteredCriteria: [WCAGCriterion] {
        WCAGDatabase.search(searchText)
    }

    private var groupedCriteria: [(category: WCAGCategory, criteria: [WCAGCriterion])] {
        if searchText.isEmpty {
            return WCAGDatabase.byCategory()
        } else {
            let grouped = Dictionary(grouping: filteredCriteria, by: \.category)
            return WCAGCategory.allCases.compactMap { cat in
                guard let items = grouped[cat], !items.isEmpty else { return nil }
                return (category: cat, criteria: items)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedCriteria, id: \.category) { group in
                    Section(group.category.rawValue) {
                        ForEach(group.criteria) { criterion in
                            criterionRow(criterion)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by code, name, or keyword")
            .navigationTitle("WCAG 2.2 Criteria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func criterionRow(_ criterion: WCAGCriterion) -> some View {
        Button {
            selectedID = criterion.id
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.sm) {
                        Text(criterion.id)
                            .font(Typography.mono)
                            .foregroundStyle(ColorTokens.brandPrimary)
                        Text("Level \(criterion.level)")
                            .font(Typography.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ColorTokens.backgroundTertiary)
                            .clipShape(Capsule())
                    }
                    Text(criterion.name)
                        .font(Typography.headline)
                    Text(criterion.description)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if selectedID == criterion.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(ColorTokens.brandPrimary)
                }
            }
        }
        .foregroundStyle(ColorTokens.textPrimary)
    }
}
