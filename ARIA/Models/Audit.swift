import Foundation
import SwiftData

@Model
final class Audit {
    var id: UUID
    var name: String
    var appName: String
    var createdDate: Date
    var modifiedDate: Date
    var status: AuditStatus

    @Relationship(deleteRule: .cascade, inverse: \AuditScreen.audit)
    var screens: [AuditScreen]

    var totalFindings: Int {
        screens.reduce(0) { $0 + $1.findings.count }
    }

    var criticalCount: Int {
        screens.reduce(0) { $0 + $1.findings.filter { $0.severity == .critical }.count }
    }

    var majorCount: Int {
        screens.reduce(0) { $0 + $1.findings.filter { $0.severity == .major }.count }
    }

    var progress: Double {
        guard !screens.isEmpty else { return 0 }
        let screensWithFindings = screens.filter { !$0.findings.isEmpty }.count
        return Double(screensWithFindings) / Double(screens.count)
    }

    init(name: String, appName: String) {
        self.id = UUID()
        self.name = name
        self.appName = appName
        self.createdDate = .now
        self.modifiedDate = .now
        self.status = .inProgress
        self.screens = []
    }
}

enum AuditStatus: String, Codable {
    case inProgress, complete
}
