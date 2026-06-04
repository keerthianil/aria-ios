import SwiftUI

struct ReportPreviewView: View {
    let audit: Audit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                reportHeader
                severitySummary
                ForEach(audit.screens.sorted(by: { $0.orderIndex < $1.orderIndex })) { screen in
                    screenSection(screen)
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: generateReportText()) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Accessibility Audit Report")
                .font(.title2.bold())
            Text(audit.appName)
                .font(Typography.title3)
                .foregroundStyle(ColorTokens.textSecondary)
            Text("Audit: \(audit.name)")
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
            Text("Generated \(Date.now, format: .dateTime.month(.wide).day().year())")
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.textTertiary)

            Divider()
        }
    }

    private var severitySummary: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Summary")
                .font(Typography.headline)

            HStack(spacing: Spacing.lg) {
                summaryBadge("Critical", count: audit.criticalCount, color: ColorTokens.severityCritical)
                summaryBadge("Major", count: audit.majorCount, color: ColorTokens.severityMajor)
                let minorCount = audit.screens.reduce(0) { $0 + $1.findings.filter { $0.severity == .minor }.count }
                summaryBadge("Minor", count: minorCount, color: ColorTokens.severityMinor)
            }
        }
    }

    private func summaryBadge(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(Typography.display)
                .foregroundStyle(color)
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func screenSection(_ screen: AuditScreen) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(screen.name)
                .font(Typography.headline)
                .padding(.top, Spacing.sm)

            ForEach(screen.findings.sorted(by: { $0.severity.sortOrder < $1.severity.sortOrder })) { finding in
                findingRow(finding, screenName: screen.name)
            }
        }
    }

    private func findingRow(_ finding: Finding, screenName: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                SeverityBadge(severity: finding.severity)
                if !finding.wcagCriterionID.isEmpty {
                    Text(finding.wcagCriterionID)
                        .font(Typography.mono)
                        .foregroundStyle(ColorTokens.brandPrimary)
                }
            }

            if !finding.findingDescription.isEmpty {
                Text(finding.findingDescription)
                    .font(Typography.callout)
            }

            if !finding.recommendation.isEmpty {
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(ColorTokens.brandAccent)
                        .font(.caption)
                    Text(finding.recommendation)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func generateReportText() -> String {
        var text = "Accessibility Audit Report\n"
        text += "App: \(audit.appName)\n"
        text += "Audit: \(audit.name)\n"
        text += "Total Findings: \(audit.totalFindings)\n\n"

        for screen in audit.screens.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            text += "--- \(screen.name) ---\n"
            for finding in screen.findings {
                text += "[\(finding.severity.displayName)] \(finding.wcagCriterionID): \(finding.findingDescription)\n"
                if !finding.recommendation.isEmpty {
                    text += "  Fix: \(finding.recommendation)\n"
                }
                text += "\n"
            }
        }
        return text
    }
}
