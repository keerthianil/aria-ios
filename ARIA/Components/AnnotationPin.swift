import SwiftUI

struct AnnotationPin: View {
    let number: Int
    let severity: Severity
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)

            Circle()
                .fill(severity.color)
                .frame(width: 28, height: 28)

            Text("\(number)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
        .accessibilityElement()
        .accessibilityLabel("Finding \(number)")
        .accessibilityValue(severity.displayName)
        .accessibilityHint("Double-tap to view or edit this finding")
        .accessibilityAddTraits(.isButton)
    }
}
