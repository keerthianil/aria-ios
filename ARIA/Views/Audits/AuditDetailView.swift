import SwiftUI
import PhotosUI

struct AuditDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var audit: Audit
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showEditAudit = false
    @State private var showReorder = false
    @State private var showRenameScreen = false
    @State private var editedScreenName = ""
    @State private var screenToRename: AuditScreen?
    @State private var screenPendingDelete: AuditScreen?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                summaryCard
                screensSection
            }
            .padding(Spacing.lg)
        }
        .navigationTitle(audit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: Spacing.md) {
                    if audit.totalFindings > 0 {
                        NavigationLink {
                            ReportPreviewView(audit: audit)
                        } label: {
                            Image(systemName: "doc.text")
                        }
                        .accessibilityLabel("View report")
                    }
                    menu
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotos,
                      maxSelectionCount: 20, matching: .images)
        .onChange(of: selectedPhotos) { _, newItems in
            Task { await importScreenshots(from: newItems) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { data in appendScreen(imageData: data) }
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showEditAudit) {
            CreateAuditView(auditToEdit: audit)
        }
        .sheet(isPresented: $showReorder) {
            ReorderScreensView(audit: audit)
        }
        .alert("Rename Screen", isPresented: $showRenameScreen) {
            TextField("Screen name", text: $editedScreenName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                screenToRename?.name = editedScreenName
                audit.touch()
            }
        }
        .confirmationDialog(
            "Delete this screen?",
            isPresented: Binding(get: { screenPendingDelete != nil },
                                 set: { if !$0 { screenPendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete Screen", role: .destructive) {
                if let screen = screenPendingDelete { deleteScreen(screen) }
                screenPendingDelete = nil
            }
            Button("Cancel", role: .cancel) { screenPendingDelete = nil }
        } message: {
            Text("This removes the screenshot and all of its findings. This can't be undone.")
        }
    }

    // MARK: - Toolbar menu

    private var menu: some View {
        Menu {
            Button {
                showEditAudit = true
            } label: {
                Label("Edit Details", systemImage: "pencil")
            }

            if audit.screens.count > 1 {
                Button {
                    showReorder = true
                } label: {
                    Label("Reorder Screens", systemImage: "arrow.up.arrow.down")
                }
            }

            Button {
                audit.status = audit.status == .complete ? .inProgress : .complete
                audit.touch()
            } label: {
                Label(
                    audit.status == .complete ? "Mark In Progress" : "Mark Complete",
                    systemImage: audit.status == .complete ? "arrow.uturn.backward" : "checkmark.circle"
                )
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .accessibilityLabel("Audit options")
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: audit.platform.iconName)
                    .foregroundStyle(ColorTokens.textSecondary)
                Text(audit.appName)
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
                Spacer()
                Text(audit.status.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(audit.status == .complete ? ColorTokens.pass.opacity(0.12) : ColorTokens.brandPrimary.opacity(0.1))
                    .foregroundStyle(audit.status == .complete ? ColorTokens.pass : ColorTokens.brandPrimary)
                    .clipShape(Capsule())
            }

            HStack(spacing: Spacing.xl) {
                statBlock("\(audit.totalFindings)", label: "Findings")
                statBlock("\(audit.screens.count)", label: "Screens")
                statBlock("\(audit.openCount)", label: "Open")
            }

            if audit.totalFindings > 0 {
                VStack(spacing: Spacing.sm) {
                    HStack(spacing: Spacing.md) {
                        ForEach(Severity.allCases) { sev in
                            let count = audit.findingsCount(for: sev)
                            if count > 0 {
                                SeverityBadge(severity: sev, count: count, style: .compact)
                            }
                        }
                        Spacer()
                    }

                    ProgressView(value: audit.resolutionProgress) {
                        Text("\(audit.resolvedCount) of \(audit.totalFindings) fixed")
                            .font(Typography.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .tint(ColorTokens.pass)

                    NavigationLink {
                        FindingsDashboardView(audit: audit)
                    } label: {
                        HStack {
                            Text("View all findings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(Typography.subheadline)
                        .foregroundStyle(ColorTokens.brandPrimary)
                    }
                }
            }
        }
        .padding(Spacing.xl)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statBlock(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(ColorTokens.brandPrimary)
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Screens List

    private var screensSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Screens")
                    .font(Typography.headline)
                Spacer()
                addScreenMenu
            }

            if audit.screens.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle",
                    title: "No screens yet",
                    message: "Import screenshots or capture a screen to start auditing.",
                    actionTitle: "Add Screenshots"
                ) {
                    showPhotoPicker = true
                }
            } else {
                ForEach(audit.sortedScreens) { screen in
                    NavigationLink {
                        AnnotationCanvasView(screen: screen, audit: audit)
                    } label: {
                        screenRow(screen)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            screenToRename = screen
                            editedScreenName = screen.name
                            showRenameScreen = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            screenPendingDelete = screen
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var addScreenMenu: some View {
        Menu {
            Button {
                showPhotoPicker = true
            } label: {
                Label("Choose from Photos", systemImage: "photo.on.rectangle")
            }
            Button {
                showCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera")
            }
        } label: {
            Label("Add", systemImage: "plus.circle")
                .font(Typography.subheadline)
                .fontWeight(.medium)
        }
        .accessibilityLabel("Add a screen")
    }

    private func screenRow(_ screen: AuditScreen) -> some View {
        HStack(spacing: Spacing.md) {
            Group {
                if let img = screen.screenshotImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(ColorTokens.backgroundTertiary)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(ColorTokens.textTertiary)
                        }
                }
            }
            .frame(width: 56, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(screen.name)
                    .font(Typography.headline)
                    .lineLimit(1)

                HStack(spacing: Spacing.sm) {
                    Text("\(screen.findings.count) finding\(screen.findings.count == 1 ? "" : "s")")
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)

                    if !screen.findings.isEmpty {
                        let worst = screen.sortedFindings.first!.severity
                        SeverityBadge(severity: worst, style: .compact)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(Spacing.md)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens annotation canvas for this screen")
    }

    // MARK: - Import

    private func importScreenshots(from items: [PhotosPickerItem]) async {
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            appendScreen(imageData: data)
        }
        selectedPhotos = []
    }

    private func appendScreen(imageData: Data) {
        let compressed = UIImage(data: imageData)?.jpegData(compressionQuality: 0.7) ?? imageData
        let index = audit.screens.count
        let screen = AuditScreen(
            name: "Screen \(index + 1)",
            screenshotData: compressed,
            orderIndex: index
        )
        screen.audit = audit
        modelContext.insert(screen)
        audit.touch()
    }

    private func deleteScreen(_ screen: AuditScreen) {
        modelContext.delete(screen)
        audit.touch()
    }
}
