import SwiftUI
import PhotosUI

struct AuditDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var audit: Audit
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var showEditTitle = false
    @State private var editedScreenName = ""
    @State private var screenToRename: AuditScreen?

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

                    Menu {
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
            }
        }
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

            HStack(spacing: Spacing.md) {
                ForEach(Severity.allCases) { sev in
                    let count = countFindings(for: sev)
                    if count > 0 {
                        SeverityBadge(severity: sev, count: count, style: .compact)
                    }
                }
                Spacer()
            }
        }
        .padding(Spacing.xl)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
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
    }

    private func countFindings(for severity: Severity) -> Int {
        audit.screens.reduce(0) { $0 + $1.findings.filter { $0.severity == severity }.count }
    }

    // MARK: - Screens List

    private var screensSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Screens")
                    .font(Typography.headline)
                Spacer()
                importButton
            }

            if audit.screens.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle",
                    title: "No screens yet",
                    message: "Import screenshots of the screens you want to audit.",
                    actionTitle: "Import Screenshots"
                ) {
                    isImporting = true
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
                            showEditTitle = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deleteScreen(screen)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .alert("Rename Screen", isPresented: $showEditTitle) {
            TextField("Screen name", text: $editedScreenName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                screenToRename?.name = editedScreenName
                audit.touch()
            }
        }
    }

    private var importButton: some View {
        PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .screenshots
        ) {
            Label("Import", systemImage: "photo.badge.plus")
                .font(Typography.subheadline)
                .fontWeight(.medium)
        }
        .onChange(of: selectedPhotos) { _, newItems in
            Task { await importScreenshots(from: newItems) }
        }
        .accessibilityHint("Import screenshots from your photo library")
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
        let startIndex = audit.screens.count
        for (i, item) in items.enumerated() {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }

            guard let image = UIImage(data: data) else { continue }
            let compressed = image.jpegData(compressionQuality: 0.7) ?? data

            let screen = AuditScreen(
                name: "Screen \(startIndex + i + 1)",
                screenshotData: compressed,
                orderIndex: startIndex + i
            )
            screen.audit = audit
            modelContext.insert(screen)
        }
        audit.touch()
        selectedPhotos = []
    }

    private func deleteScreen(_ screen: AuditScreen) {
        modelContext.delete(screen)
        audit.touch()
    }
}
