import SwiftUI
import SwiftData

struct AnnotationCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    let screen: AuditScreen
    let audit: Audit
    @State private var showFindingForm = false
    @State private var selectedFinding: Finding?

    @State private var currentZoom: CGFloat = 1.0
    @State private var totalZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {
                screenshotLayer(in: geo)
                pinLayer(in: geo)
            }
            .scaleEffect(totalZoom * currentZoom)
            .offset(offset)
            .gesture(zoomGesture)
            .simultaneousGesture(dragGesture)
        }
        .navigationTitle(screen.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text("\(screen.findings.count) finding\(screen.findings.count == 1 ? "" : "s")")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        totalZoom = 1.0
                        currentZoom = 1.0
                        offset = .zero
                        lastOffset = .zero
                    }
                } label: {
                    Label("Reset Zoom", systemImage: "arrow.up.left.and.arrow.down.right")
                }
            }
        }
        .sheet(isPresented: $showFindingForm) {
            if let finding = selectedFinding {
                FindingFormSheet(finding: finding, onDelete: {
                    modelContext.delete(finding)
                    audit.touch()
                    showFindingForm = false
                })
            }
        }
    }

    // MARK: - Screenshot Layer

    private func screenshotLayer(in geo: GeometryProxy) -> some View {
        Group {
            if let img = screen.screenshotImage {
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
            let scale = totalZoom * currentZoom
            let adjustedX = (location.x - offset.width) / scale
            let adjustedY = (location.y - offset.height) / scale
            let normalizedX = adjustedX / geo.size.width
            let normalizedY = adjustedY / geo.size.height
            addPin(at: normalizedX, y: normalizedY)
        }
        .accessibilityLabel("Screenshot of \(screen.name)")
        .accessibilityHint("Double-tap to place an accessibility finding marker")
    }

    // MARK: - Pin Layer

    private func pinLayer(in geo: GeometryProxy) -> some View {
        ForEach(Array(screen.sortedFindings.enumerated()), id: \.element.id) { index, finding in
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

    // MARK: - Gestures

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                currentZoom = value.magnification
            }
            .onEnded { value in
                totalZoom *= value.magnification
                totalZoom = min(max(totalZoom, 1.0), 5.0)
                currentZoom = 1.0
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard totalZoom > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    // MARK: - Actions

    private func addPin(at x: Double, y: Double) {
        let clamped = (x: min(max(x, 0), 1), y: min(max(y, 0), 1))
        let finding = Finding(pinX: clamped.x, pinY: clamped.y)
        finding.screen = screen
        modelContext.insert(finding)
        audit.touch()
        selectedFinding = finding
        showFindingForm = true
    }
}
