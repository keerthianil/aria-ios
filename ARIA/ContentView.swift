import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .audits
    @AppStorage("aria.hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

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
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onChange(of: showOnboarding) { _, isShowing in
            if !isShowing { hasSeenOnboarding = true }
        }
        .onAppear {
            if !hasSeenOnboarding { showOnboarding = true }
        }
    }
}
