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
            Text(audit.name)
                .font(Typography.headline)
            Text(audit.appName)
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
            HStack(spacing: Spacing.md) {
                Label("\(audit.screens.count) screens", systemImage: "rectangle.on.rectangle")
                Label("\(audit.totalFindings) findings", systemImage: "exclamationmark.circle")
                if audit.criticalCount > 0 {
                    SeverityBadge(severity: .critical, count: audit.criticalCount)
                }
            }
            .font(Typography.caption)
            .foregroundStyle(ColorTokens.textSecondary)
        }
        .padding(.vertical, Spacing.xs)
    }

    private func deleteAudits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(audits[index])
        }
    }
}
