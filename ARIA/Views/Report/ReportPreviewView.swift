import SwiftUI

struct ReportPreviewView: View {
    let audit: Audit
    @State private var pdfData: Data?
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                reportHeader
                severitySummary
                ForEach(audit.sortedScreens) { screen in
                    screenSection(screen)
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let pdfData {
                    let doc = PDFDocument(data: pdfData, filename: "\(audit.appName)-Audit-Report.pdf")
                    ShareLink(item: doc, preview: SharePreview("\(audit.appName) — Audit Report", image: Image(systemName: "doc.text"))) {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share PDF report")
                } else {
                    Button {
                        generatePDF()
                    } label: {
                        Label("Generate PDF", systemImage: "doc.text")
                    }
                    .accessibilityLabel("Generate PDF report")
                }
            }
        }
        .onAppear { generatePDF() }
    }

    // MARK: - Header

    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Accessibility Audit Report")
                .font(.title2.bold())

            HStack(spacing: Spacing.sm) {
                Image(systemName: audit.platform.iconName)
                Text(audit.appName)
            }
            .font(Typography.title3)
            .foregroundStyle(ColorTokens.textSecondary)

            Text(audit.name)
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)

            if !audit.auditorName.isEmpty {
                Text("Auditor: \(audit.auditorName)")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }

            Text("Generated \(Date.now, format: .dateTime.month(.wide).day().year())")
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.textTertiary)

            Divider()
        }
    }

    // MARK: - Severity Summary

    private var severitySummary: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Summary")
                .font(Typography.headline)

            HStack(spacing: Spacing.md) {
                ForEach(Severity.allCases) { sev in
                    let count = audit.screens.reduce(0) { $0 + $1.findings.filter { $0.severity == sev }.count }
                    summaryCard(sev.displayName, count: count, color: sev.color)
                }
            }
        }
    }

    private func summaryCard(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(Typography.caption2)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) \(label)")
    }

    // MARK: - Screen Sections

    private func screenSection(_ screen: AuditScreen) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(screen.name)
                    .font(Typography.headline)
                Spacer()
                Text("\(screen.findings.count) finding\(screen.findings.count == 1 ? "" : "s")")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            .padding(.top, Spacing.sm)

            ForEach(screen.sortedFindings) { finding in
                findingRow(finding)
            }
        }
    }

    private func findingRow(_ finding: Finding) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                SeverityBadge(severity: finding.severity)
                if !finding.wcagCriterionID.isEmpty {
                    Text(finding.wcagCriterionID)
                        .font(Typography.mono)
                        .foregroundStyle(ColorTokens.brandPrimary)
                    if let name = WCAGDatabase.criterion(for: finding.wcagCriterionID)?.name {
                        Text(name)
                            .font(Typography.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if finding.isFixed {
                    Label("Fixed", systemImage: "checkmark.circle.fill")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.pass)
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
        .accessibilityElement(children: .combine)
    }

    // MARK: - PDF

    private func generatePDF() {
        pdfData = PDFReportService.generateReport(for: audit)
    }
}

struct PDFDocument: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { doc in
            doc.data
        }
        FileRepresentation(exportedContentType: .pdf) { doc in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(doc.filename)
            try doc.data.write(to: url)
            return SentTransferredFile(url)
        }
    }
}
