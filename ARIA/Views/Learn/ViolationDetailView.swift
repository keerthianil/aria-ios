import SwiftUI

/// Rich, plain-language detail page for a WCAG criterion, opened from the Learn tab.
struct ViolationDetailView: View {
    let criterionID: String

    private var criterion: WCAGCriterion? { WCAGDatabase.criterion(for: criterionID) }
    private var guidance: LearnGuidance { LearnGuidance.forCriterion(criterionID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                if let criterion {
                    header(criterion)
                    section("What it means", body: criterion.description)
                }
                section("Who this affects", body: guidance.whoAffected)
                section("How to test it", body: guidance.howToTest)
                if let example = guidance.commonFailure {
                    section("Common failure", body: example)
                }
            }
            .padding(Spacing.lg)
        }
        .navigationTitle(criterion?.name ?? "Criterion")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func header(_ criterion: WCAGCriterion) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text(criterion.id)
                    .font(Typography.mono)
                    .foregroundStyle(ColorTokens.brandPrimary)
                Text("Level \(criterion.level)")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ColorTokens.backgroundSecondary)
                    .clipShape(Capsule())
                Label(criterion.category.rawValue, systemImage: criterion.category.iconName)
                    .font(Typography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            Text(criterion.name)
                .font(.title2.bold())
        }
        .accessibilityElement(children: .combine)
    }

    private func section(_ title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.brandPrimary)
            Text(body)
                .font(Typography.body)
                .foregroundStyle(ColorTokens.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Plain-language "who/how/example" guidance. Specific entries for the common mobile violations,
/// with a sensible category-based fallback for the rest.
struct LearnGuidance {
    let whoAffected: String
    let howToTest: String
    let commonFailure: String?

    static func forCriterion(_ id: String) -> LearnGuidance {
        if let specific = specifics[id] { return specific }
        let category = WCAGDatabase.criterion(for: id)?.category
        switch category {
        case .perceivable:
            return LearnGuidance(
                whoAffected: "People who are blind, have low vision, or are colorblind — anyone who can't perceive the content the way it's presented.",
                howToTest: "Turn on VoiceOver and see whether the information is announced. Check colors with the built-in Contrast Checker.",
                commonFailure: nil)
        case .operable:
            return LearnGuidance(
                whoAffected: "People with motor differences, and anyone using VoiceOver, Switch Control, or a keyboard instead of touch.",
                howToTest: "Try to complete the task using only VoiceOver swipes, or Full Keyboard Access. If you get stuck, that's a finding.",
                commonFailure: nil)
        case .understandable:
            return LearnGuidance(
                whoAffected: "People with cognitive differences, and anyone under time pressure or unfamiliar with the interface.",
                howToTest: "Look for clear labels, predictable behavior, and helpful error messages. Trigger an error on purpose and read what's shown.",
                commonFailure: nil)
        case .robust:
            return LearnGuidance(
                whoAffected: "People using any assistive technology that relies on the accessibility tree being correct.",
                howToTest: "Use VoiceOver and the Accessibility Inspector to confirm each control announces its name, role, and current value/state.",
                commonFailure: nil)
        case .none:
            return LearnGuidance(
                whoAffected: "People who rely on assistive technology.",
                howToTest: "Test the flow with VoiceOver enabled.",
                commonFailure: nil)
        }
    }

    private static let specifics: [String: LearnGuidance] = [
        "1.4.3": LearnGuidance(
            whoAffected: "People with low vision or color vision deficiency, and anyone using the app in bright sunlight.",
            howToTest: "Use ARIA's Contrast Checker: sample the text color and the background behind it. Body text needs 4.5:1; large text needs 3:1.",
            commonFailure: "Light gray placeholder text on a white field, or #999 body text on #121212."),
        "1.1.1": LearnGuidance(
            whoAffected: "People who are blind or have low vision and rely on VoiceOver to describe images.",
            howToTest: "Enable VoiceOver and swipe to each image. If it reads \"image\" or a filename instead of a meaningful description, it fails.",
            commonFailure: "Product photos and icon buttons that announce nothing useful."),
        "2.5.5": LearnGuidance(
            whoAffected: "People with tremors, limited dexterity, or large fingers, and anyone using the app on the move.",
            howToTest: "Check that tappable targets are at least 44×44pt. The visual can be smaller if the hit area is padded to 44pt.",
            commonFailure: "Tiny icon-only close buttons and tightly grouped social icons."),
        "3.3.2": LearnGuidance(
            whoAffected: "People using screen readers, and anyone who loses the placeholder once they start typing.",
            howToTest: "Focus each input with VoiceOver. Every field should have a persistent, programmatic label — not just placeholder text.",
            commonFailure: "Search and form fields whose only label is placeholder text that disappears on focus."),
        "2.4.3": LearnGuidance(
            whoAffected: "VoiceOver and keyboard users who move through the screen in sequence.",
            howToTest: "Swipe right repeatedly with VoiceOver and note the order. It should match the logical visual reading order.",
            commonFailure: "Focus jumping from a header straight to the footer, skipping the main content."),
        "1.4.1": LearnGuidance(
            whoAffected: "People who are colorblind or can't distinguish the color being used to signal meaning.",
            howToTest: "Ask: if I removed all color, would I still understand the state? Add an icon, label, or shape as a second cue.",
            commonFailure: "A green dot as the only \"active\" indicator, or red-only form errors.")
    ]
}
