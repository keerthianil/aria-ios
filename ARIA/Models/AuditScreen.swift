import Foundation
import SwiftData
import UIKit

@Model
final class AuditScreen {
    var id: UUID
    var name: String
    var screenshotData: Data?
    var orderIndex: Int
    var audit: Audit?

    @Relationship(deleteRule: .cascade, inverse: \Finding.screen)
    var findings: [Finding]

    var screenshotImage: UIImage? {
        guard let screenshotData else { return nil }
        return UIImage(data: screenshotData)
    }

    var sortedFindings: [Finding] {
        findings.sorted { $0.severity.sortOrder < $1.severity.sortOrder }
    }

    init(name: String, screenshotData: Data? = nil, orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.screenshotData = screenshotData
        self.orderIndex = orderIndex
        self.findings = []
    }
}
