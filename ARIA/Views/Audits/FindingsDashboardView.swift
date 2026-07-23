import SwiftUI

/// Cross-screen list of every finding in an audit, with resolution tracking and filters.
/// Tapping a finding deep-links to its pin on the annotation canvas.
struct FindingsDashboardView: View {
    let audit: Audit

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All", open = "Open", fixed = "Fixed"
        var id: String { rawValue }
    }

    @State private var severityFilter: Severity?
    @State private var statusFilter: StatusFilter = .all

    private var findings: [(screen: AuditScreen, finding: Finding)] {
        audit.sortedScreens.flatMap { screen in
            screen.sortedFindings.map { (screen, $0) }
        }
        .filter { pair in
            (severityFilter == nil || pair.finding.severity == severityFilter)
            && (statusFilter == .all
                || (statusFilter == .fixed && pair.finding.isFixed)
                || (statusFilter == .open && !pair.finding.isFixed))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                progressCard
                filters
                if findings.isEmpty {
                    Text("No findings match these filters.")
                        .font(Typography.callout)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.xxl)
                } else {
                    ForEach(findings, id: \.finding.id) { pair in
                        NavigationLink {
                            AnnotationCanvasView(screen: pair.screen, audit: audit, focusFindingID: pair.finding.id)
                        } label: {
                            findingRow(pair.screen, pair.finding)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("All Findings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Resolution")
                    .font(Typography.headline)
                Spacer()
                Text("\(audit.resolvedCount) of \(audit.totalFindings) fixed")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            ProgressView(value: audit.resolutionProgress)
                .tint(ColorTokens.pass)
        }
        .padding(Spacing.lg)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(audit.resolvedCount) of \(audit.totalFindings) findings fixed")
    }

    // MARK: - Filters

    private var filters: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Picker("Status", selection: $statusFilter) {
                ForEach(StatusFilter.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    filterChip(title: "All severities", isOn: severityFilter == nil) {
                        severityFilter = nil
                    }
                    ForEach(Severity.allCases) { sev in
                        filterChip(title: sev.displayName, tint: sev.color, isOn: severityFilter == sev) {
                            severityFilter = severityFilter == sev ? nil : sev
                        }
                    }
                }
            }
        }
    }

    private func filterChip(title: String, tint: Color = ColorTokens.brandPrimary, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption)
                .fontWeight(.medium)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isOn ? tint.opacity(0.15) : ColorTokens.backgroundSecondary)
                .foregroundStyle(isOn ? tint : ColorTokens.textSecondary)
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    // MARK: - Row

    private func findingRow(_ screen: AuditScreen, _ finding: Finding) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: finding.severity.iconName)
                .foregroundStyle(finding.severity.color)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.sm) {
                    if !finding.wcagCriterionID.isEmpty {
                        Text(finding.wcagCriterionID)
                            .font(Typography.mono)
                            .foregroundStyle(ColorTokens.brandPrimary)
                    }
                    Text(screen.name)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                Text(finding.findingDescription.isEmpty ? "No description yet" : finding.findingDescription)
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            if finding.isFixed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ColorTokens.pass)
            }
        }
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens this finding on its screen")
    }
}
