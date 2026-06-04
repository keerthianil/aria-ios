import Foundation
import SwiftData

@Model
final class AuditScreen {
    var id: UUID
    var name: String
    var screenshotData: Data?
    var orderIndex: Int
    var audit: Audit?

    @Relationship(deleteRule: .cascade, inverse: \Finding.screen)
    var findings: [Finding]

    init(name: String, screenshotData: Data? = nil, orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.screenshotData = screenshotData
        self.orderIndex = orderIndex
        self.findings = []
    }
}
