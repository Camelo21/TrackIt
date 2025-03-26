import UserNotifications

/// Handles all notification-related tasks
class NotificationManager {
    static let shared = NotificationManager() // Singleton instance

    /// **Requests permission to show notifications**
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error requesting notification permissions: \(error)")
            } else if granted {
                print("✅ Notifications permission granted")
            } else {
                print("⚠️ Notifications permission denied")
            }
        }
    }

    /// **Schedules a reward notification when a milestone is reached**
    func scheduleRewardNotification(for milestone: Milestone, reward: RewardMilestone, delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Milestone Reached!"
        content.body = "You've completed \(milestone.name) and earned: \(reward.rewardName) \(reward.rewardIcon)!"
        content.sound = .default

        // ✅ Set a delay before showing the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled in \(delay) seconds.")
            }
        }
    }

    /// **Handles when a user taps a notification**
    func handleNotification(response: UNNotificationResponse) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRewardView"), object: nil)
        }
    }
}
