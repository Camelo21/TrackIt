import SwiftUI
import SwiftData

@main
struct TrackItApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // ✅ iOS-compatible delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Milestone.self,
            RewardMilestone.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowRewardView"))) { _ in
                    showRewardView()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    /// **Handles showing the Reward View when a notification is tapped**
    private func showRewardView() {
        print("🎉 Reward View should appear!")
    }
}
