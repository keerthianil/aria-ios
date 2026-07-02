import SwiftUI

struct CriterionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedID: String
    @State private var searchText = ""

    private var groupedCriteria: [(category: WCAGCategory, criteria: [WCAGCriterion])] {
        if searchText.isEmpty {
            return WCAGDatabase.byCategory()
        } else {
            let filtered = WCAGDatabase.search(searchText)
            let grouped = Dictionary(grouping: filtered, by: \.category)
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
                    Section {
                        ForEach(group.criteria) { criterion in
                            criterionRow(criterion)
                        }
                    } header: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: group.category.iconName)
                            Text(group.category.rawValue)
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
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: Spacing.sm) {
                        Text(criterion.id)
                            .font(Typography.mono)
                            .foregroundStyle(ColorTokens.brandPrimary)
                        Text("Level \(criterion.level)")
                            .font(.system(size: 10, weight: .medium))
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
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ColorTokens.brandPrimary)
                }
            }
        }
        .foregroundStyle(ColorTokens.textPrimary)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selectedID == criterion.id ? .isSelected : [])
    }
}
