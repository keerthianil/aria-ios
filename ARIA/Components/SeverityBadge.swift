import SwiftUI

struct SeverityBadge: View {
    let severity: Severity
    var count: Int? = nil
    var style: BadgeStyle = .capsule

    enum BadgeStyle {
        case capsule, compact
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.iconName)
                .font(.system(size: style == .compact ? 8 : 10))
                .foregroundStyle(severity.color)

            if let count {
                Text("\(count)")
                    .font(Typography.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(severity.color)
            }

            if style == .capsule {
                Text(severity.displayName)
                    .font(Typography.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(severity.color)
            }
        }
        .padding(.horizontal, style == .compact ? 6 : 8)
        .padding(.vertical, style == .compact ? 3 : 5)
        .background(severity.color.opacity(0.1))
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count.map { "\($0) " } ?? "")\(severity.displayName)")
    }
}
