import Foundation
import SwiftData

struct MockDataService {
    static func populateIfEmpty(context: ModelContext) {
        let descriptor = FetchDescriptor<Audit>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let audit = Audit(name: "Q2 Accessibility Review", appName: "Spotify iOS")

        let screens: [(String, [(Double, Double, String, Severity, String, String)])] = [
            ("Home Feed", [
                (0.3, 0.15, "1.4.3", .critical,
                 "\"Recently Played\" section headers use #999999 text on #121212 background. Contrast ratio is 2.8:1, needs 4.5:1.",
                 "Increase text lightness to #B3B3B3 or above to achieve 4.5:1 minimum."),
                (0.5, 0.4, "1.1.1", .major,
                 "Album artwork in \"Made For You\" row has no alt text. VoiceOver reads \"image\" with no context.",
                 "Add alt text with album name and artist: \"Daily Mix 1 - Based on Radiohead, The National\""),
                (0.7, 0.6, "2.4.6", .major,
                 "Section headers (\"Recently Played\", \"Made For You\") are not marked as headings in the accessibility tree.",
                 "Add heading trait to section titles for screen reader navigation."),
                (0.2, 0.8, "1.4.1", .minor,
                 "\"Now Playing\" indicator uses only a green color dot. No additional shape or label.",
                 "Add a secondary indicator (e.g., speaker icon or \"Playing\" label) alongside the color dot."),
            ]),
            ("Now Playing", [
                (0.2, 0.7, "2.5.5", .major,
                 "Skip-back and skip-forward buttons are 32x32pt, below the 44x44pt iOS minimum touch target.",
                 "Increase touch target to at least 44x44pt. Visual size can remain smaller if hit area is expanded."),
                (0.8, 0.3, "4.1.2", .major,
                 "Heart/save button does not announce its toggled state. VoiceOver reads \"heart\" but not \"saved\" or \"not saved\".",
                 "Add accessibility value that reflects the saved state: \"Saved\" or \"Not saved\"."),
                (0.5, 0.9, "1.4.11", .minor,
                 "Progress bar track has insufficient contrast against the dark background (1.8:1, needs 3:1).",
                 "Increase progress bar track brightness or add a subtle border."),
            ]),
            ("Search", [
                (0.5, 0.3, "2.4.6", .critical,
                 "Genre cards in Browse have no heading structure. Screen reader navigates as a flat list of unlabeled images.",
                 "Add heading hierarchy. Genre names should be headings, and cards should have descriptive labels."),
                (0.3, 0.7, "3.3.2", .major,
                 "Search field has no visible label. Placeholder text disappears on focus, leaving no indication of purpose.",
                 "Add a persistent label above or beside the search field, or use a floating label pattern."),
            ]),
            ("Library", [
                (0.6, 0.2, "2.4.3", .major,
                 "Focus order skips the filter pills (Playlists, Artists, Albums) and jumps directly to content.",
                 "Ensure filter controls receive focus before the content they filter."),
                (0.4, 0.5, "1.3.1", .minor,
                 "List items don't convey whether they are playlists, albums, or artists programmatically. Only visual icons differentiate them.",
                 "Add accessibility labels that include content type: \"Daily Mix 1, Playlist\" not just \"Daily Mix 1\"."),
                (0.7, 0.8, "4.1.3", .minor,
                 "When switching between filter tabs, no status message announces the updated content count.",
                 "Announce result count after filter change: \"Showing 24 playlists.\""),
            ]),
            ("Settings", [
                (0.5, 0.5, "1.4.3", .minor,
                 "\"About\" section footer text uses #666666 on #121212 (3.5:1 ratio). Body text requires 4.5:1.",
                 "Lighten footer text to #999999 minimum."),
            ]),
        ]

        for (index, (screenName, findings)) in screens.enumerated() {
            let screen = AuditScreen(name: screenName, orderIndex: index)
            screen.audit = audit
            context.insert(screen)

            for (px, py, wcag, severity, desc, rec) in findings {
                let finding = Finding(
                    pinX: px,
                    pinY: py,
                    wcagCriterionID: wcag,
                    severity: severity,
                    findingDescription: desc,
                    recommendation: rec
                )
                finding.screen = screen
                context.insert(finding)
            }
        }

        context.insert(audit)
    }
}
