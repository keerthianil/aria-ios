import SwiftUI

struct AuditDetailView: View {
    let audit: Audit

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                summaryCard
                screensList
            }
            .padding(Spacing.lg)
        }
        .navigationTitle(audit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("Report") {
                    ReportPreviewView(audit: audit)
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: Spacing.md) {
            Text(audit.appName)
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)

            HStack(spacing: Spacing.xl) {
                VStack {
                    Text("\(audit.totalFindings)")
                        .font(Typography.display)
                        .foregroundStyle(ColorTokens.brandPrimary)
                    Text("Findings")
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }

                VStack {
                    Text("\(audit.screens.count)")
                        .font(Typography.display)
                        .foregroundStyle(ColorTokens.brandPrimary)
                    Text("Screens")
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }

            HStack(spacing: Spacing.md) {
                severityCount(.critical, count: audit.criticalCount)
                severityCount(.major, count: audit.majorCount)
                let minorCount = audit.screens.reduce(0) { $0 + $1.findings.filter { $0.severity == .minor }.count }
                severityCount(.minor, count: minorCount)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func severityCount(_ severity: Severity, count: Int) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(severityColor(severity))
                .frame(width: 8, height: 8)
            Text("\(count) \(severity.displayName)")
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
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

    private var screensList: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Screens")
                .font(Typography.headline)

            if audit.screens.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle",
                    title: "No screens yet",
                    message: "Add screenshots of the screens you want to audit.",
                    actionTitle: "Import Screenshots",
                    action: {}
                )
            } else {
                ForEach(audit.screens.sorted(by: { $0.orderIndex < $1.orderIndex })) { screen in
                    NavigationLink {
                        AnnotationCanvasView(screen: screen)
                    } label: {
                        screenRow(screen)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func screenRow(_ screen: AuditScreen) -> some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorTokens.backgroundTertiary)
                .frame(width: 60, height: 40)
                .overlay {
                    if let data = screen.screenshotData,
                       let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .foregroundStyle(ColorTokens.textTertiary)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(screen.name)
                    .font(Typography.headline)
                Text("\(screen.findings.count) findings")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
