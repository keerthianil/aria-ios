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

    var totalFindings: Int {
        screens.reduce(0) { $0 + $1.findings.count }
    }

    var criticalCount: Int {
        countFindings(withSeverity: .critical)
    }

    var majorCount: Int {
        countFindings(withSeverity: .major)
    }

    var moderateCount: Int {
        countFindings(withSeverity: .moderate)
    }

    var minorCount: Int {
        countFindings(withSeverity: .minor)
    }

    var openCount: Int {
        screens.reduce(0) { $0 + $1.findings.filter { $0.status == .open }.count }
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

    private func countFindings(withSeverity severity: Severity) -> Int {
        screens.reduce(0) { $0 + $1.findings.filter { $0.severity == severity }.count }
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
