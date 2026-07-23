import SwiftUI
import SwiftData
import AVFoundation

struct AnnotationCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let screen: AuditScreen
    let audit: Audit
    /// When set (e.g. from the findings dashboard), that finding is opened on appear.
    var focusFindingID: UUID? = nil

    @State private var showFindingForm = false
    @State private var selectedFinding: Finding?

    // Transform state. `zoom` is the committed scale; `offset` the committed pan.
    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let frame = imageFrame(in: geo.size)
            ZStack {
                ColorTokens.backgroundPrimary
                canvasContent(frame: frame, size: geo.size)
                    .scaleEffect(zoom)
                    .offset(offset)
                    .gesture(magnification)
                    .simultaneousGesture(pan)
            }
            .clipped()
        }
        .navigationTitle(screen.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    ContrastCheckerView(screen: screen, audit: audit)
                } label: {
                    Image(systemName: "circle.lefthalf.filled")
                }
                .accessibilityLabel("Check color contrast")
            }
            if zoom > 1.0 {
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        withMotion { zoom = 1.0; lastZoom = 1.0; offset = .zero; lastOffset = .zero }
                    } label: {
                        Label("Reset Zoom", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            hintBar
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
        .onAppear {
            if let focusFindingID, let match = screen.findings.first(where: { $0.id == focusFindingID }) {
                selectedFinding = match
                showFindingForm = true
            }
        }
    }

    // MARK: - Canvas content (image + pins live in one coordinate space)

    private func canvasContent(frame: CGRect, size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            screenshotView(frame: frame)

            ForEach(Array(screen.sortedFindings.enumerated()), id: \.element.id) { index, finding in
                AnnotationPin(
                    number: index + 1,
                    severity: finding.severity,
                    isSelected: selectedFinding?.id == finding.id
                )
                .position(
                    x: frame.minX + CGFloat(finding.pinX) * frame.width,
                    y: frame.minY + CGFloat(finding.pinY) * frame.height
                )
                .onTapGesture { select(finding) }
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        // Tap location arrives in this view's local (pre-transform) space — the same space
        // the pins are positioned in — so placement stays correct at any zoom/pan.
        .onTapGesture { location in placePin(at: location, in: frame) }
    }

    private func screenshotView(frame: CGRect) -> some View {
        Group {
            if let img = screen.screenshotImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: frame.width, height: frame.height)
                    .clipped()
                    .position(x: frame.midX, y: frame.midY)
                    .accessibilityLabel("Screenshot of \(screen.name)")
                    .accessibilityHint("Tap anywhere on the screenshot to place a finding marker")
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorTokens.backgroundSecondary)
                    .frame(width: frame.width, height: frame.height)
                    .overlay {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                            Text("Tap anywhere to add a finding")
                                .font(Typography.callout)
                        }
                        .foregroundStyle(ColorTokens.textTertiary)
                    }
                    .position(x: frame.midX, y: frame.midY)
            }
        }
    }

    private var hintBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "hand.tap")
            Text(screen.findings.isEmpty
                 ? "Tap the screenshot to place your first finding"
                 : "\(screen.findings.count) finding\(screen.findings.count == 1 ? "" : "s") · pinch to zoom, tap to add")
        }
        .font(Typography.caption)
        .foregroundStyle(ColorTokens.textSecondary)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Geometry

    private func imageFrame(in size: CGSize) -> CGRect {
        if let img = screen.screenshotImage, img.size.width > 0, img.size.height > 0 {
            return AVMakeRect(aspectRatio: img.size, insideRect: CGRect(origin: .zero, size: size))
        }
        // No image: use a portrait-ish box centered in the container.
        let w = min(size.width - Spacing.xl * 2, 320)
        let h = min(size.height - Spacing.xl * 2, w * 1.6)
        return CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h)
    }

    // MARK: - Gestures

    private var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                zoom = min(max(lastZoom * value.magnification, 1.0), 5.0)
            }
            .onEnded { _ in
                lastZoom = zoom
                if zoom <= 1.0 {
                    withMotion { offset = .zero; lastOffset = .zero }
                }
            }
    }

    private var pan: some Gesture {
        // minimumDistance keeps a stationary tap from being consumed as a tiny drag.
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard zoom > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }

    // MARK: - Actions

    private func select(_ finding: Finding) {
        selectedFinding = finding
        showFindingForm = true
    }

    private func placePin(at location: CGPoint, in frame: CGRect) {
        let nx = (location.x - frame.minX) / frame.width
        let ny = (location.y - frame.minY) / frame.height
        guard nx >= 0, nx <= 1, ny >= 0, ny <= 1 else { return }
        let finding = Finding(pinX: nx, pinY: ny)
        finding.screen = screen
        modelContext.insert(finding)
        audit.touch()
        selectedFinding = finding
        showFindingForm = true
    }

    private func withMotion(_ changes: @escaping () -> Void) {
        if reduceMotion {
            changes()
        } else {
            withAnimation(.spring(response: 0.3)) { changes() }
        }
    }
}
