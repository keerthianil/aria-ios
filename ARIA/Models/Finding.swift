import Foundation
import SwiftData

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
    }
}

enum Severity: String, Codable, CaseIterable, Identifiable {
    case critical, major, minor, advisory
    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var sortOrder: Int {
        switch self {
        case .critical: 0
        case .major: 1
        case .minor: 2
        case .advisory: 3
        }
    }
}

enum FindingStatus: String, Codable {
    case open, resolved
}
