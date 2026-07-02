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
    var status: FindingStatus
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
        self.status = .open
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

    var numericLevel: Int {
        switch self {
        case .critical: 1
        case .major: 2
        case .moderate: 3
        case .minor: 4
        }
    }

    var sortOrder: Int { numericLevel }

    var color: Color {
        switch self {
        case .critical: ColorTokens.severityCritical
        case .major: ColorTokens.severityMajor
        case .moderate: ColorTokens.severityModerate
        case .minor: ColorTokens.severityMinor
        }
    }

    var iconName: String {
        switch self {
        case .critical: "exclamationmark.octagon.fill"
        case .major: "exclamationmark.triangle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .minor: "info.circle.fill"
        }
    }
}

enum FindingStatus: String, Codable {
    case open, resolved
}
