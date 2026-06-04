import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .audits

    enum Tab: String {
        case audits, learn
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            AuditListView()
                .tabItem {
                    Label("Audits", systemImage: "checklist")
                }
                .tag(Tab.audits)

            LearnHomeView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(Tab.learn)
        }
        .tint(ColorTokens.brandPrimary)
    }
}
