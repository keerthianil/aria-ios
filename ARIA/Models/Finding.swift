import Foundation
import SwiftData
import SwiftUI

@Model
final class Finding {
    var id: UUID
    var pinX: Double
    var pinY: Double
    var wcagCriterionID: String
    var severity: Severity
    var findingDescription: String
    var recommendation: String
    /// Single source of truth for resolution state. (Replaces the old `status`/`isFixed`
    /// pair, which could drift out of sync.)
    var isFixed: Bool
    var createdAt: Date
    var screen: AuditScreen?

    init(
        pinX: Double,
        pinY: Double,
        wcagCriterionID: String = "",
        severity: Severity = .major,
        findingDescription: String = "",
        recommendation: String = ""
    ) {
        self.id = UUID()
        self.pinX = pinX
        self.pinY = pinY
        self.wcagCriterionID = wcagCriterionID
        self.severity = severity
        self.findingDescription = findingDescription
        self.recommendation = recommendation
        self.isFixed = false
        self.createdAt = .now
    }

    var criterionName: String {
        WCAGDatabase.criteria.first { $0.id == wcagCriterionID }?.name ?? ""
    }
}

enum Severity: String, Codable, CaseIterable, Identifiable {
    case critical, major, moderate, minor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .critical: "Critical"
        case .major: "Major"
        case .moderate: "Moderate"
        case .minor: "Minor"
        }
    }

    /// Lower number = more severe. Used for sorting findings worst-first.
    var sortOrder: Int {
        switch self {
        case .critical: 1
        case .major: 2
        case .moderate: 3
        case .minor: 4
        }
    }

    /// SwiftUI color — the single source of truth for this severity's color.
    var color: Color {
        switch self {
        case .critical: ColorTokens.severityCritical
        case .major: ColorTokens.severityMajor
        case .moderate: ColorTokens.severityModerate
        case .minor: ColorTokens.severityMinor
        }
    }

    /// UIKit bridge derived from the same `color`, so PDF rendering never duplicates RGB values.
    var uiColor: UIColor { UIColor(color) }

    var iconName: String {
        switch self {
        case .critical: "exclamationmark.octagon.fill"
        case .major: "exclamationmark.triangle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .minor: "info.circle.fill"
        }
    }

    /// One-line plain-language explanation of what this severity means, surfaced in the UI.
    var guidance: String {
        switch self {
        case .critical: "Blocks a core task for users of assistive technology."
        case .major: "Significantly harder to use, but a workaround may exist."
        case .moderate: "Noticeable friction that should be fixed."
        case .minor: "Small issue or polish item."
        }
    }
}
