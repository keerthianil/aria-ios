import SwiftUI

struct AnnotationPin: View {
    let number: Int
    let severity: Severity
    let isSelected: Bool

    private var pinColor: Color {
        switch severity {
        case .critical: ColorTokens.severityCritical
        case .major: ColorTokens.severityMajor
        case .minor: ColorTokens.severityMinor
        case .advisory: ColorTokens.severityAdvisory
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

            Circle()
                .fill(pinColor)
                .frame(width: 24, height: 24)

            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
        .accessibilityElement()
        .accessibilityLabel("Finding \(number), \(severity.displayName)")
    }
}
