import Foundation
import SwiftData

struct MockDataService {
    private static let hasSeededKey = "aria.hasSeededMockData"

    /// Seeds sample audits exactly once (first launch). After that, an empty list is a real
    /// empty state — deleting every audit no longer silently repopulates the samples.
    static func populateIfEmpty(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: hasSeededKey) else { return }

        let descriptor = FetchDescriptor<Audit>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            createSpotifyAudit(context: context)
            createAirbnbAudit(context: context)
        }
        UserDefaults.standard.set(true, forKey: hasSeededKey)
    }

    private static func createSpotifyAudit(context: ModelContext) {
        let audit = Audit(name: "Q2 Accessibility Review", appName: "Spotify iOS", platform: .iOS, auditorName: "Keerthi Anil")

        let screens: [(String, [(Double, Double, String, Severity, String, String)])] = [
            ("Home Feed", [
                (0.3, 0.15, "1.4.3", .critical,
                 "\"Recently Played\" section headers use #999999 text on #121212 background. Contrast ratio is 2.8:1, needs 4.5:1.",
                 "Increase text lightness to #B3B3B3 or above to achieve 4.5:1 minimum."),
                (0.5, 0.4, "1.1.1", .major,
                 "Album artwork in \"Made For You\" row has no alt text. VoiceOver reads \"image\" with no context.",
                 "Add alt text with album name and artist: \"Daily Mix 1 — Based on Radiohead, The National.\""),
                (0.7, 0.6, "2.4.6", .major,
                 "Section headers (\"Recently Played\", \"Made For You\") are not marked as headings in the accessibility tree.",
                 "Add heading trait to section titles for screen reader navigation."),
                (0.2, 0.8, "1.4.1", .moderate,
                 "\"Now Playing\" indicator uses only a green color dot. No additional shape or label.",
                 "Add a secondary indicator (e.g., speaker icon or \"Playing\" label) alongside the color dot."),
            ]),
            ("Now Playing", [
                (0.2, 0.7, "2.5.8", .major,
                 "Skip-back and skip-forward buttons are 32x32pt, below the 44x44pt iOS minimum touch target.",
                 "Increase touch target to at least 44x44pt. Visual size can remain smaller if hit area is expanded."),
                (0.8, 0.3, "4.1.2", .major,
                 "Heart/save button does not announce its toggled state. VoiceOver reads \"heart\" but not \"saved\" or \"not saved\".",
                 "Add accessibility value that reflects the saved state: \"Saved\" or \"Not saved\"."),
                (0.5, 0.9, "1.4.11", .moderate,
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
                (0.4, 0.5, "1.3.1", .moderate,
                 "List items don't convey whether they are playlists, albums, or artists programmatically.",
                 "Add accessibility labels that include content type: \"Daily Mix 1, Playlist\" not just \"Daily Mix 1\"."),
                (0.7, 0.8, "4.1.3", .minor,
                 "When switching between filter tabs, no status message announces the updated content count.",
                 "Announce result count after filter change: \"Showing 24 playlists.\""),
            ]),
            ("Settings", [
                (0.5, 0.5, "1.4.3", .moderate,
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
                    pinX: px, pinY: py,
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

    private static func createAirbnbAudit(context: ModelContext) {
        let audit = Audit(name: "Booking Flow Review", appName: "Airbnb iOS", platform: .iOS, auditorName: "Keerthi Anil")

        let screens: [(String, [(Double, Double, String, Severity, String, String)])] = [
            ("Search Results", [
                (0.4, 0.35, "1.1.1", .critical,
                 "Listing photos in the horizontal carousel have no alt text. VoiceOver reads only \"image 1 of 5\".",
                 "Add descriptive alt text: \"Modern studio apartment with floor-to-ceiling windows, city view.\""),
                (0.7, 0.6, "2.5.8", .major,
                 "Heart/favorite icon is 28x28pt with no padding. Touch target is below 44x44pt minimum.",
                 "Expand touch target to at least 44x44pt using content padding or hit area extension."),
                (0.3, 0.8, "1.4.11", .moderate,
                 "Map pin icons for listings lack sufficient contrast against the map background (2.1:1).",
                 "Increase pin contrast or add a white border/shadow to ensure 3:1 minimum."),
            ]),
            ("Listing Detail", [
                (0.5, 0.15, "2.4.3", .major,
                 "Focus order jumps from the photo gallery directly to reviews, skipping price, amenities, and host info.",
                 "Restructure focus order to follow visual reading order: photos → title → price → amenities → reviews."),
                (0.6, 0.45, "1.3.1", .major,
                 "Amenity icons (WiFi, Kitchen, Pool) are decorative images with no programmatic labels.",
                 "Add accessibility labels to each amenity: \"WiFi included\", \"Kitchen available\"."),
                (0.4, 0.7, "3.3.2", .moderate,
                 "Date picker has no visible label. \"Check-in\" and \"Check-out\" only appear as placeholder text.",
                 "Add persistent labels above the date fields."),
            ]),
            ("Checkout", [
                (0.5, 0.4, "3.3.1", .critical,
                 "Payment form validation errors appear only as a red border — no text description of the error.",
                 "Add descriptive error text below each invalid field: \"Card number must be 16 digits.\""),
                (0.3, 0.6, "2.1.1", .major,
                 "Custom dropdown for number of guests cannot be operated with Switch Control or Full Keyboard Access.",
                 "Replace with a native iOS picker or ensure custom control supports all assistive technology input methods."),
            ]),
        ]

        for (index, (screenName, findings)) in screens.enumerated() {
            let screen = AuditScreen(name: screenName, orderIndex: index)
            screen.audit = audit
            context.insert(screen)

            for (px, py, wcag, severity, desc, rec) in findings {
                let finding = Finding(
                    pinX: px, pinY: py,
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
