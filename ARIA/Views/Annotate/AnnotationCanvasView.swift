import SwiftUI
import SwiftData

struct AnnotationCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    let screen: AuditScreen
    @State private var showFindingForm = false
    @State private var selectedFinding: Finding?
    @State private var newPinLocation: CGPoint?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                screenshotView(in: geo)
                pinOverlay(in: geo)
            }
        }
        .navigationTitle(screen.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFindingForm) {
            if let finding = selectedFinding {
                FindingFormSheet(finding: finding)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text("\(screen.findings.count) findings")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
    }

    private func screenshotView(in geo: GeometryProxy) -> some View {
        Group {
            if let data = screen.screenshotData,
               let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Rectangle()
                    .fill(ColorTokens.backgroundSecondary)
                    .overlay {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                            Text("Tap anywhere to add a finding")
                                .font(Typography.callout)
                        }
                        .foregroundStyle(ColorTokens.textTertiary)
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { location in
            let normalizedX = location.x / geo.size.width
            let normalizedY = location.y / geo.size.height
            addPin(at: normalizedX, y: normalizedY)
        }
    }

    private func pinOverlay(in geo: GeometryProxy) -> some View {
        ForEach(Array(screen.findings.enumerated()), id: \.element.id) { index, finding in
            AnnotationPin(
                number: index + 1,
                severity: finding.severity,
                isSelected: selectedFinding?.id == finding.id
            )
            .position(
                x: finding.pinX * geo.size.width,
                y: finding.pinY * geo.size.height
            )
            .onTapGesture {
                selectedFinding = finding
                showFindingForm = true
            }
        }
    }

    private func addPin(at x: Double, y: Double) {
        let finding = Finding(pinX: x, pinY: y)
        finding.screen = screen
        modelContext.insert(finding)
        selectedFinding = finding
        showFindingForm = true
    }
}
