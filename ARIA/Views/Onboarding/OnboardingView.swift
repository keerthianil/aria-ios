import SwiftUI

/// First-run explainer for the audit → annotate → report loop. Skippable, accessible.
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    private struct Page: Identifiable {
        let id = Int.random(in: 0...Int.max)
        let icon: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(icon: "checklist",
             title: "Audit any app",
             body: "Create an audit for an app you're reviewing, then import screenshots of the screens you want to check."),
        Page(icon: "mappin.and.ellipse",
             title: "Pin what's wrong",
             body: "Tap a screenshot to drop a marker, tag the WCAG criterion, set severity, and write what's wrong and how to fix it."),
        Page(icon: "circle.lefthalf.filled",
             title: "Check contrast on the spot",
             body: "Sample any two points on a screenshot to get the live WCAG contrast ratio — and save a failure straight to your findings."),
        Page(icon: "doc.text",
             title: "Export a report devs read",
             body: "Generate a clean PDF with annotated screenshots, severities, and WCAG references — ready to share.")
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)

            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: Spacing.xl) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(ColorTokens.brandPrimary.opacity(0.12))
                                .frame(width: 120, height: 120)
                            Image(systemName: item.icon)
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundStyle(ColorTokens.brandPrimary)
                        }
                        .accessibilityHidden(true)

                        VStack(spacing: Spacing.md) {
                            Text(item.title)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                            Text(item.body)
                                .font(Typography.body)
                                .foregroundStyle(ColorTokens.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 320)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .tag(index)
                    .accessibilityElement(children: .combine)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if page < pages.count - 1 { page += 1 } else { finish() }
            } label: {
                Text(page < pages.count - 1 ? "Next" : "Start auditing")
                    .font(Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(ColorTokens.brandPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .background(ColorTokens.backgroundPrimary)
        .interactiveDismissDisabled()
    }

    private func finish() {
        isPresented = false
    }
}
