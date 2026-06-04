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
}

struct WCAGDatabase {
    static let criteria: [WCAGCriterion] = [
        WCAGCriterion(id: "1.1.1", name: "Non-text Content", level: "A", category: .perceivable,
                      description: "All non-text content has a text alternative that serves the equivalent purpose."),
        WCAGCriterion(id: "1.3.1", name: "Info and Relationships", level: "A", category: .perceivable,
                      description: "Information, structure, and relationships conveyed through presentation can be programmatically determined."),
        WCAGCriterion(id: "1.3.4", name: "Orientation", level: "AA", category: .perceivable,
                      description: "Content does not restrict its view and operation to a single display orientation."),
        WCAGCriterion(id: "1.4.1", name: "Use of Color", level: "A", category: .perceivable,
                      description: "Color is not used as the only visual means of conveying information."),
        WCAGCriterion(id: "1.4.3", name: "Contrast (Minimum)", level: "AA", category: .perceivable,
                      description: "Text has a contrast ratio of at least 4.5:1. Large text has a contrast ratio of at least 3:1."),
        WCAGCriterion(id: "1.4.4", name: "Resize Text", level: "AA", category: .perceivable,
                      description: "Text can be resized without assistive technology up to 200 percent without loss of content or functionality."),
        WCAGCriterion(id: "1.4.11", name: "Non-text Contrast", level: "AA", category: .perceivable,
                      description: "UI components and graphical objects have a contrast ratio of at least 3:1 against adjacent colors."),
        WCAGCriterion(id: "2.1.1", name: "Keyboard", level: "A", category: .operable,
                      description: "All functionality is operable through a keyboard interface."),
        WCAGCriterion(id: "2.4.3", name: "Focus Order", level: "A", category: .operable,
                      description: "Focusable components receive focus in an order that preserves meaning and operability."),
        WCAGCriterion(id: "2.4.6", name: "Headings and Labels", level: "AA", category: .operable,
                      description: "Headings and labels describe topic or purpose."),
        WCAGCriterion(id: "2.4.7", name: "Focus Visible", level: "AA", category: .operable,
                      description: "Any keyboard operable user interface has a mode of operation where the keyboard focus indicator is visible."),
        WCAGCriterion(id: "2.5.5", name: "Target Size (Enhanced)", level: "AAA", category: .operable,
                      description: "The size of the target for pointer inputs is at least 44 by 44 CSS pixels."),
        WCAGCriterion(id: "2.5.8", name: "Target Size (Minimum)", level: "AA", category: .operable,
                      description: "Targets have an area of at least 24 by 24 CSS pixels."),
        WCAGCriterion(id: "3.1.1", name: "Language of Page", level: "A", category: .understandable,
                      description: "The default human language of each page can be programmatically determined."),
        WCAGCriterion(id: "3.3.1", name: "Error Identification", level: "A", category: .understandable,
                      description: "If an input error is automatically detected, the item in error is identified and the error is described to the user in text."),
        WCAGCriterion(id: "3.3.2", name: "Labels or Instructions", level: "A", category: .understandable,
                      description: "Labels or instructions are provided when content requires user input."),
        WCAGCriterion(id: "4.1.2", name: "Name, Role, Value", level: "A", category: .robust,
                      description: "For all user interface components, the name and role can be programmatically determined."),
        WCAGCriterion(id: "4.1.3", name: "Status Messages", level: "AA", category: .robust,
                      description: "Status messages can be programmatically determined through role or properties so they can be presented to the user without receiving focus."),
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
        WCAGCategory.allCases.map { cat in
            (category: cat, criteria: criteria.filter { $0.category == cat })
        }
    }
}
