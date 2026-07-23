import SwiftUI
import SwiftData
import AVFoundation

/// Sample two points on a screenshot and get the live WCAG contrast ratio between them.
struct ContrastCheckerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let screen: AuditScreen
    let audit: Audit

    @State private var foregroundPoint = CGPoint(x: 0.5, y: 0.35)
    @State private var backgroundPoint = CGPoint(x: 0.5, y: 0.6)
    @State private var didAddFinding = false

    private let canvasSpace = "contrastCanvas"

    private var foregroundColor: UIColor {
        screen.screenshotImage?.averageColor(atNormalized: foregroundPoint) ?? .label
    }
    private var backgroundColor: UIColor {
        screen.screenshotImage?.averageColor(atNormalized: backgroundPoint) ?? .systemBackground
    }
    private var ratio: Double {
        ContrastMath.ratio(foregroundColor, backgroundColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            canvas
            resultsPanel
        }
        .navigationTitle("Contrast Checker")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Canvas

    private var canvas: some View {
        GeometryReader { geo in
            let frame = imageFrame(in: geo.size)
            ZStack {
                ColorTokens.backgroundPrimary
                if let img = screen.screenshotImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                        .accessibilityHidden(true)
                } else {
                    Text("This screen has no screenshot to sample.")
                        .font(Typography.callout)
                        .foregroundStyle(ColorTokens.textSecondary)
                }

                sampler(point: $foregroundPoint, label: "T", tint: .white, frame: frame)
                sampler(point: $backgroundPoint, label: "BG", tint: .white, frame: frame)
            }
            .coordinateSpace(name: canvasSpace)
        }
    }

    private func sampler(point: Binding<CGPoint>, label: String, tint: Color, frame: CGRect) -> some View {
        let position = CGPoint(
            x: frame.minX + point.wrappedValue.x * frame.width,
            y: frame.minY + point.wrappedValue.y * frame.height
        )
        return ZStack {
            Circle()
                .strokeBorder(.white, lineWidth: 3)
                .background(Circle().stroke(.black, lineWidth: 1))
                .frame(width: 34, height: 34)
                .shadow(color: .black.opacity(0.4), radius: 3)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .position(position)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(canvasSpace))
                .onChanged { value in
                    guard frame.width > 0, frame.height > 0 else { return }
                    let nx = (value.location.x - frame.minX) / frame.width
                    let ny = (value.location.y - frame.minY) / frame.height
                    point.wrappedValue = CGPoint(x: min(max(nx, 0), 1), y: min(max(ny, 0), 1))
                }
        )
        .accessibilityLabel(label == "T" ? "Text color sample point" : "Background color sample point")
        .accessibilityHint("Drag to move the sample point")
    }

    // MARK: - Results

    private var resultsPanel: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.lg) {
                swatch(Color(foregroundColor), caption: "Text")
                Text(String(format: "%.2f:1", ratio))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(ColorTokens.textPrimary)
                    .accessibilityLabel(String(format: "Contrast ratio %.2f to 1", ratio))
                swatch(Color(backgroundColor), caption: "Background")
            }

            VStack(spacing: Spacing.sm) {
                ForEach(ContrastMath.checks(for: ratio)) { check in
                    HStack {
                        Image(systemName: check.passes ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(check.passes ? ColorTokens.pass : ColorTokens.error)
                        Text(check.label)
                            .font(Typography.subheadline)
                        Spacer()
                        Text(check.passes ? "Pass" : "Fail")
                            .font(Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(check.passes ? ColorTokens.pass : ColorTokens.error)
                    }
                    .accessibilityElement(children: .combine)
                }
            }

            Button {
                addAsFinding()
            } label: {
                Label(didAddFinding ? "Added to findings" : "Save as finding",
                      systemImage: didAddFinding ? "checkmark.circle.fill" : "plus.circle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(didAddFinding ? ColorTokens.pass.opacity(0.15) : ColorTokens.brandPrimary)
                    .foregroundStyle(didAddFinding ? ColorTokens.pass : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(didAddFinding || ratio >= 4.5)
            .opacity(ratio >= 4.5 ? 0.5 : 1)
        }
        .padding(Spacing.lg)
        .background(ColorTokens.backgroundSecondary)
    }

    private func swatch(_ color: Color, caption: String) -> some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ColorTokens.borderDefault))
            Text(caption)
                .font(Typography.caption2)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .accessibilityHidden(true)
    }

    // MARK: - Helpers

    private func imageFrame(in size: CGSize) -> CGRect {
        if let img = screen.screenshotImage, img.size.width > 0, img.size.height > 0 {
            return AVMakeRect(aspectRatio: img.size, insideRect: CGRect(origin: .zero, size: size))
        }
        return CGRect(origin: .zero, size: size)
    }

    private func addAsFinding() {
        let finding = Finding(
            pinX: foregroundPoint.x,
            pinY: foregroundPoint.y,
            wcagCriterionID: "1.4.3",
            severity: ratio < 3.0 ? .critical : .major,
            findingDescription: String(format: "Text contrast is %.2f:1 here, below the 4.5:1 minimum for normal text.", ratio),
            recommendation: "Increase the contrast between the text and its background to at least 4.5:1 (3:1 for large text)."
        )
        finding.screen = screen
        modelContext.insert(finding)
        audit.touch()
        didAddFinding = true
    }
}
