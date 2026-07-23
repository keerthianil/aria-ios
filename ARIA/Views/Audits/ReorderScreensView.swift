import SwiftUI

/// Drag-to-reorder the screens in an audit. Writes the new order back to `orderIndex`.
struct ReorderScreensView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var audit: Audit

    @State private var ordered: [AuditScreen] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(ordered) { screen in
                    HStack(spacing: Spacing.md) {
                        if let img = screen.screenshotImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        Text(screen.name)
                            .font(Typography.headline)
                        Spacer()
                        Text("\(screen.findings.count)")
                            .font(Typography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                    }
                }
                .onMove(perform: move)
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Reorder Screens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { ordered = audit.sortedScreens }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, screen) in ordered.enumerated() {
            screen.orderIndex = index
        }
        audit.touch()
    }
}
