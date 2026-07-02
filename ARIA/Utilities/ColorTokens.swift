import SwiftUI

enum ColorTokens {
    static let brandPrimary = Color("BrandPrimary")
    static let brandAccent = Color("BrandAccent")

    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    static let borderDefault = Color(.separator)

    static let severityCritical = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let severityMajor = Color(red: 234/255, green: 88/255, blue: 12/255)
    static let severityModerate = Color(red: 202/255, green: 138/255, blue: 4/255)
    static let severityMinor = Color(red: 100/255, green: 116/255, blue: 139/255)

    static let pass = Color(red: 22/255, green: 163/255, blue: 74/255)
    static let error = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let warning = Color(red: 234/255, green: 88/255, blue: 12/255)
    static let success = Color(red: 22/255, green: 163/255, blue: 74/255)
}
