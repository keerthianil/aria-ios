import SwiftUI

struct LearnHomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Common Mobile Violations") {
                    learnRow(
                        icon: "textformat.size",
                        title: "Low Contrast Text",
                        subtitle: "79.1% of top websites fail this",
                        criterion: "1.4.3"
                    )
                    learnRow(
                        icon: "photo",
                        title: "Missing Alt Text",
                        subtitle: "58.2% of pages lack alt text on images",
                        criterion: "1.1.1"
                    )
                    learnRow(
                        icon: "hand.tap",
                        title: "Small Touch Targets",
                        subtitle: "Apple requires 44x44pt minimum",
                        criterion: "2.5.5"
                    )
                    learnRow(
                        icon: "text.badge.xmark",
                        title: "Missing Form Labels",
                        subtitle: "~50% of forms lack proper labels",
                        criterion: "3.3.2"
                    )
                    learnRow(
                        icon: "arrow.triangle.branch",
                        title: "Focus Order Issues",
                        subtitle: "Screen reader navigation doesn't match visual order",
                        criterion: "2.4.3"
                    )
                    learnRow(
                        icon: "paintbrush",
                        title: "Color-Only Information",
                        subtitle: "Using color as the sole indicator of state",
                        criterion: "1.4.1"
                    )
                }

                Section("WCAG 2.2 Quick Reference") {
                    ForEach(WCAGDatabase.byCategory(), id: \.category) { group in
                        NavigationLink {
                            criteriaList(group.category, criteria: group.criteria)
                        } label: {
                            HStack {
                                Text(group.category.rawValue)
                                    .font(Typography.headline)
                                Spacer()
                                Text("\(group.criteria.count) criteria")
                                    .font(Typography.caption)
                                    .foregroundStyle(ColorTokens.textSecondary)
                            }
                        }
                    }
                }

                Section("Testing Guides") {
                    NavigationLink {
                        voiceOverGuide
                    } label: {
                        Label("VoiceOver Testing Basics", systemImage: "speaker.wave.3")
                    }
                    NavigationLink {
                        contrastGuide
                    } label: {
                        Label("Checking Contrast Ratios", systemImage: "circle.lefthalf.filled")
                    }
                }
            }
            .navigationTitle("Learn")
        }
    }

    private func learnRow(icon: String, title: String, subtitle: String, criterion: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(ColorTokens.brandPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.headline)
                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            Spacer()
            Text(criterion)
                .font(Typography.mono)
                .foregroundStyle(ColorTokens.textTertiary)
        }
    }

    private func criteriaList(_ category: WCAGCategory, criteria: [WCAGCriterion]) -> some View {
        List(criteria) { criterion in
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(criterion.id)
                        .font(Typography.mono)
                        .foregroundStyle(ColorTokens.brandPrimary)
                    Text("Level \(criterion.level)")
                        .font(Typography.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ColorTokens.backgroundSecondary)
                        .clipShape(Capsule())
                }
                Text(criterion.name)
                    .font(Typography.headline)
                Text(criterion.description)
                    .font(Typography.callout)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            .padding(.vertical, Spacing.xs)
        }
        .navigationTitle(category.rawValue)
    }

    private var voiceOverGuide: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("VoiceOver Testing Basics")
                    .font(.title2.bold())

                guideStep("1", "Enable VoiceOver", "Settings > Accessibility > VoiceOver. Or use the Accessibility Shortcut (triple-click side button).")
                guideStep("2", "Navigate with gestures", "Swipe right to move to the next element. Swipe left to go back. Double-tap to activate.")
                guideStep("3", "Listen for", "Does every element have a meaningful label? Is the reading order logical? Are interactive elements announced as buttons/links?")
                guideStep("4", "Document findings", "Use ARIA to capture what VoiceOver reads (or fails to read) and map it to WCAG criteria.")
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("VoiceOver Testing")
    }

    private var contrastGuide: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Checking Contrast Ratios")
                    .font(.title2.bold())

                guideStep("1", "Minimum ratios", "Body text: 4.5:1. Large text (18pt+ or 14pt+ bold): 3:1. UI components: 3:1.")
                guideStep("2", "How to check", "Use the Digital Color Meter app (built into macOS) to sample foreground and background colors. Calculate the ratio.")
                guideStep("3", "Common failures", "Light gray text on white backgrounds. Placeholder text in inputs. Disabled state text that's too faint.")
                guideStep("4", "Document in ARIA", "When you find a contrast failure, note the colors, the ratio, and which WCAG criterion it violates (1.4.3 for text, 1.4.11 for UI components).")
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Contrast Ratios")
    }

    private func guideStep(_ number: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text(number)
                .font(Typography.mono)
                .foregroundStyle(ColorTokens.brandPrimary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline)
                Text(body)
                    .font(Typography.callout)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
    }
}
