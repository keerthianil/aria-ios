import Foundation
import SwiftData

@Model
final class Audit {
    var id: UUID
    var name: String
    var appName: String
    var platform: Platform
    var auditorName: String
    var createdDate: Date
    var modifiedDate: Date
    var status: AuditStatus

    @Relationship(deleteRule: .cascade, inverse: \AuditScreen.audit)
    var screens: [AuditScreen]

    var allFindings: [Finding] {
        screens.flatMap { $0.findings }
    }

    var totalFindings: Int { allFindings.count }

    var criticalCount: Int { findingsCount(for: .critical) }
    var majorCount: Int { findingsCount(for: .major) }
    var moderateCount: Int { findingsCount(for: .moderate) }
    var minorCount: Int { findingsCount(for: .minor) }

    /// Findings still needing a fix (single source of truth: `isFixed`).
    var openCount: Int {
        allFindings.filter { !$0.isFixed }.count
    }

    /// Findings marked fixed.
    var resolvedCount: Int {
        allFindings.filter { $0.isFixed }.count
    }

    /// 0.0–1.0 share of findings resolved. Returns 1.0 when there are no findings.
    var resolutionProgress: Double {
        guard totalFindings > 0 else { return 1.0 }
        return Double(resolvedCount) / Double(totalFindings)
    }

    /// Reusable severity count — used by the UI and the PDF so nothing recomputes this by hand.
    func findingsCount(for severity: Severity) -> Int {
        allFindings.filter { $0.severity == severity }.count
    }

    var sortedScreens: [AuditScreen] {
        screens.sorted { $0.orderIndex < $1.orderIndex }
    }

    init(name: String, appName: String, platform: Platform = .iOS, auditorName: String = "") {
        self.id = UUID()
        self.name = name
        self.appName = appName
        self.platform = platform
        self.auditorName = auditorName
        self.createdDate = .now
        self.modifiedDate = .now
        self.status = .inProgress
        self.screens = []
    }

    func touch() {
        modifiedDate = .now
    }
}

enum AuditStatus: String, Codable {
    case inProgress, complete

    var displayName: String {
        switch self {
        case .inProgress: "In Progress"
        case .complete: "Complete"
        }
    }
}

enum Platform: String, Codable, CaseIterable, Identifiable {
    case iOS, android, web

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iOS: "iOS"
        case .android: "Android"
        case .web: "Web"
        }
    }

    var iconName: String {
        switch self {
        case .iOS: "iphone"
        case .android: "candybarphone"
        case .web: "globe"
        }
    }
}
