import SwiftUI

enum ColorTokens {
    static let brandPrimary = Color(red: 37/255, green: 99/255, blue: 235/255)
    static let brandAccent = Color(red: 124/255, green: 58/255, blue: 237/255)

    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)

    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    static let borderDefault = Color(uiColor: .separator)

    static let severityCritical = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let severityMajor = Color(red: 234/255, green: 88/255, blue: 12/255)
    static let severityMinor = Color(red: 202/255, green: 138/255, blue: 4/255)
    static let severityAdvisory = Color(red: 37/255, green: 99/255, blue: 235/255)

    static let pass = Color(red: 22/255, green: 163/255, blue: 74/255)
    static let error = Color.red
    static let warning = Color.orange
    static let success = Color.green
}
