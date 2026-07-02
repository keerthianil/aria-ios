import Foundation

struct WCAGCriterion: Identifiable, Hashable {
    let id: String
    let name: String
    let level: String
    let category: WCAGCategory
    let description: String

    var displayID: String { id }
    var fullTitle: String { "\(id) \(name)" }
}

enum WCAGCategory: String, CaseIterable, Identifiable {
    case perceivable = "Perceivable"
    case operable = "Operable"
    case understandable = "Understandable"
    case robust = "Robust"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .perceivable: "eye"
        case .operable: "hand.tap"
        case .understandable: "brain.head.profile"
        case .robust: "gearshape.2"
        }
    }
}

struct WCAGDatabase {
    static let criteria: [WCAGCriterion] = [
        // MARK: Perceivable
        WCAGCriterion(id: "1.1.1", name: "Non-text Content", level: "A", category: .perceivable,
                      description: "All non-text content has a text alternative that serves the equivalent purpose."),
        WCAGCriterion(id: "1.3.1", name: "Info and Relationships", level: "A", category: .perceivable,
                      description: "Information, structure, and relationships conveyed through presentation can be programmatically determined."),
        WCAGCriterion(id: "1.3.4", name: "Orientation", level: "AA", category: .perceivable,
                      description: "Content does not restrict its view and operation to a single display orientation."),
        WCAGCriterion(id: "1.3.5", name: "Identify Input Purpose", level: "AA", category: .perceivable,
                      description: "The purpose of each input field collecting user information can be programmatically determined."),
        WCAGCriterion(id: "1.4.1", name: "Use of Color", level: "A", category: .perceivable,
                      description: "Color is not used as the only visual means of conveying information, indicating an action, or distinguishing a visual element."),
        WCAGCriterion(id: "1.4.3", name: "Contrast (Minimum)", level: "AA", category: .perceivable,
                      description: "Text has a contrast ratio of at least 4.5:1. Large text (18pt+ or 14pt+ bold) has a ratio of at least 3:1."),
        WCAGCriterion(id: "1.4.4", name: "Resize Text", level: "AA", category: .perceivable,
                      description: "Text can be resized up to 200% without loss of content or functionality."),
        WCAGCriterion(id: "1.4.10", name: "Reflow", level: "AA", category: .perceivable,
                      description: "Content can be presented without loss of information at 320 CSS pixels wide without requiring horizontal scrolling."),
        WCAGCriterion(id: "1.4.11", name: "Non-text Contrast", level: "AA", category: .perceivable,
                      description: "UI components and graphical objects have a contrast ratio of at least 3:1 against adjacent colors."),
        WCAGCriterion(id: "1.4.12", name: "Text Spacing", level: "AA", category: .perceivable,
                      description: "No loss of content when overriding line height, paragraph spacing, letter spacing, or word spacing."),
        WCAGCriterion(id: "1.4.13", name: "Content on Hover or Focus", level: "AA", category: .perceivable,
                      description: "Additional content triggered by hover or focus is dismissible, hoverable, and persistent."),

        // MARK: Operable
        WCAGCriterion(id: "2.1.1", name: "Keyboard", level: "A", category: .operable,
                      description: "All functionality is operable through a keyboard or assistive technology interface."),
        WCAGCriterion(id: "2.1.2", name: "No Keyboard Trap", level: "A", category: .operable,
                      description: "If keyboard focus can be moved to a component, focus can also be moved away using only the keyboard."),
        WCAGCriterion(id: "2.4.3", name: "Focus Order", level: "A", category: .operable,
                      description: "Focusable components receive focus in an order that preserves meaning and operability."),
        WCAGCriterion(id: "2.4.4", name: "Link Purpose (In Context)", level: "A", category: .operable,
                      description: "The purpose of each link can be determined from the link text alone, or from the link together with its context."),
        WCAGCriterion(id: "2.4.6", name: "Headings and Labels", level: "AA", category: .operable,
                      description: "Headings and labels describe topic or purpose."),
        WCAGCriterion(id: "2.4.7", name: "Focus Visible", level: "AA", category: .operable,
                      description: "Any keyboard operable user interface has a visible keyboard focus indicator."),
        WCAGCriterion(id: "2.4.11", name: "Focus Not Obscured (Minimum)", level: "AA", category: .operable,
                      description: "When a component receives focus, it is not entirely hidden by author-created content."),
        WCAGCriterion(id: "2.5.1", name: "Pointer Gestures", level: "A", category: .operable,
                      description: "All functionality that uses multipoint or path-based gestures can be operated with a single pointer."),
        WCAGCriterion(id: "2.5.5", name: "Target Size (Enhanced)", level: "AAA", category: .operable,
                      description: "The size of the target for pointer inputs is at least 44 by 44 CSS pixels."),
        WCAGCriterion(id: "2.5.7", name: "Dragging Movements", level: "AA", category: .operable,
                      description: "Functionality that uses dragging can be achieved with a single pointer without dragging."),
        WCAGCriterion(id: "2.5.8", name: "Target Size (Minimum)", level: "AA", category: .operable,
                      description: "Targets have an area of at least 24 by 24 CSS pixels, with exceptions for inline and text targets."),

        // MARK: Understandable
        WCAGCriterion(id: "3.1.1", name: "Language of Page", level: "A", category: .understandable,
                      description: "The default human language of each page can be programmatically determined."),
        WCAGCriterion(id: "3.2.1", name: "On Focus", level: "A", category: .understandable,
                      description: "When a component receives focus, it does not initiate a change of context."),
        WCAGCriterion(id: "3.2.2", name: "On Input", level: "A", category: .understandable,
                      description: "Changing the setting of a UI component does not automatically cause a change of context."),
        WCAGCriterion(id: "3.2.6", name: "Consistent Help", level: "A", category: .understandable,
                      description: "Help mechanisms occur in the same relative order on each page."),
        WCAGCriterion(id: "3.3.1", name: "Error Identification", level: "A", category: .understandable,
                      description: "If an input error is automatically detected, the item in error is identified and described to the user in text."),
        WCAGCriterion(id: "3.3.2", name: "Labels or Instructions", level: "A", category: .understandable,
                      description: "Labels or instructions are provided when content requires user input."),
        WCAGCriterion(id: "3.3.7", name: "Redundant Entry", level: "A", category: .understandable,
                      description: "Information previously entered by the user is auto-populated or available for selection."),

        // MARK: Robust
        WCAGCriterion(id: "4.1.2", name: "Name, Role, Value", level: "A", category: .robust,
                      description: "For all UI components, the name and role can be programmatically determined; states and values can be programmatically set."),
        WCAGCriterion(id: "4.1.3", name: "Status Messages", level: "AA", category: .robust,
                      description: "Status messages can be programmatically determined so they can be presented without receiving focus."),
    ]

    static func search(_ query: String) -> [WCAGCriterion] {
        guard !query.isEmpty else { return criteria }
        let lowered = query.lowercased()
        return criteria.filter {
            $0.id.lowercased().contains(lowered) ||
            $0.name.lowercased().contains(lowered) ||
            $0.description.lowercased().contains(lowered)
        }
    }

    static func byCategory() -> [(category: WCAGCategory, criteria: [WCAGCriterion])] {
        WCAGCategory.allCases.compactMap { cat in
            let items = criteria.filter { $0.category == cat }
            return items.isEmpty ? nil : (category: cat, criteria: items)
        }
    }

    static func criterion(for id: String) -> WCAGCriterion? {
        criteria.first { $0.id == id }
    }
}
