import SwiftUI
import SwiftData

struct AuditListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Audit.modifiedDate, order: .reverse) private var audits: [Audit]
    @State private var showCreateAudit = false

    var body: some View {
        NavigationStack {
            Group {
                if audits.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No audits yet",
                        message: "Start your first accessibility review — pick any app on your phone.",
                        actionTitle: "Create First Audit"
                    ) {
                        showCreateAudit = true
                    }
                } else {
                    List {
                        ForEach(audits) { audit in
                            NavigationLink(value: audit) {
                                auditRow(audit)
                            }
                        }
                        .onDelete(perform: deleteAudits)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Audits")
            .navigationDestination(for: Audit.self) { audit in
                AuditDetailView(audit: audit)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateAudit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create new audit")
                }
            }
            .sheet(isPresented: $showCreateAudit) {
                CreateAuditView()
            }
            .onAppear {
                MockDataService.populateIfEmpty(context: modelContext)
            }
        }
    }

    private func auditRow(_ audit: Audit) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(audit.name)
                    .font(Typography.headline)
                Spacer()
                statusBadge(audit.status)
            }

            HStack(spacing: Spacing.sm) {
                Image(systemName: audit.platform.iconName)
                    .font(.caption)
                Text(audit.appName)
                    .font(Typography.subheadline)
            }
            .foregroundStyle(ColorTokens.textSecondary)

            HStack(spacing: Spacing.md) {
                Label("\(audit.screens.count) screens", systemImage: "rectangle.on.rectangle")
                Label("\(audit.totalFindings) findings", systemImage: "exclamationmark.circle")
                if audit.criticalCount > 0 {
                    SeverityBadge(severity: .critical, count: audit.criticalCount, style: .compact)
                }
            }
            .font(Typography.caption)
            .foregroundStyle(ColorTokens.textSecondary)

            Text(audit.modifiedDate, format: .dateTime.month(.abbreviated).day().year())
                .font(Typography.caption2)
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private func statusBadge(_ status: AuditStatus) -> some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status == .complete ? ColorTokens.pass.opacity(0.12) : ColorTokens.brandPrimary.opacity(0.1))
            .foregroundStyle(status == .complete ? ColorTokens.pass : ColorTokens.brandPrimary)
            .clipShape(Capsule())
    }

    private func deleteAudits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(audits[index])
        }
    }
}
