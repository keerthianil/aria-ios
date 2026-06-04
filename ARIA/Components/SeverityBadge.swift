import SwiftUI

struct SeverityBadge: View {
    let severity: Severity
    var count: Int? = nil

    private var badgeColor: Color {
        switch severity {
        case .critical: ColorTokens.severityCritical
        case .major: ColorTokens.severityMajor
        case .minor: ColorTokens.severityMinor
        case .advisory: ColorTokens.severityAdvisory
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)

            if let count {
                Text("\(count)")
                    .font(Typography.caption2)
                    .foregroundStyle(badgeColor)
            }

            Text(severity.displayName)
                .font(Typography.caption2)
                .foregroundStyle(badgeColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.1))
        .clipShape(Capsule())
    }
}
