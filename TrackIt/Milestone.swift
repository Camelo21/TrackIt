import SwiftData
import SwiftUI

/// **Represents a milestone that a user wants to track.**
@Model
class Milestone {
    var name: String       // The name of the milestone (e.g., "Days Without Smoking")
    var startDate: Date    // The date the milestone starts tracking
    var rewardMilestones: [RewardMilestone] // List of rewards at different time milestones
    var trackingType: String // "days" for consecutive days, "count" for total actions
    var daysTracked: Int   // The number of days the user has tracked (only for "days" mode)
    var actionsCompleted: Int // Number of total actions completed (only for "count" mode)
    var lastTrackedDate: Date // ✅ Keeps track of the last time the milestone was updated

    /// **Initializes a new milestone with multiple reward milestones.**
    init(name: String, startDate: Date = Date(), rewardMilestones: [RewardMilestone] = [], trackingType: String = "days", daysTracked: Int = 0, actionsCompleted: Int = 0) {
        self.name = name
        self.startDate = startDate
        self.rewardMilestones = rewardMilestones
        self.trackingType = trackingType
        self.daysTracked = daysTracked
        self.actionsCompleted = actionsCompleted
        self.lastTrackedDate = Date() // ✅ Set last tracked date to today initially
    }

    /// **Checks if the user missed a day and resets the streak if necessary.**
    func updateDaysTracked() {
        let calendar = Calendar.current
        let today = Date()

        // ✅ Calculate how many days passed since last update
        let daysSinceLastTracked = calendar.dateComponents([.day], from: lastTrackedDate, to: today).day ?? 0

        if trackingType == "days" && daysSinceLastTracked > 1 {
            print("❌ User missed a day, resetting streak!")
            daysTracked = 0 // ✅ Reset days if user skipped a day
        }

        // ✅ Update last tracked date to today
        lastTrackedDate = today
    }

    /// **Calculates how many days have passed since the milestone started.**
    var daysSinceStart: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }

    /// **Finds the next reward that has not yet been reached.**
    var nextReward: RewardMilestone? {
        return rewardMilestones
            .filter { trackingType == "days" ? $0.daysRequired > daysTracked : $0.daysRequired > actionsCompleted }
            .sorted { $0.daysRequired < $1.daysRequired }
            .first
    }

    /// **Calculates how many actions or days are left until the next reward.**
    var progressUntilNextReward: Int {
        guard let nextReward = nextReward else { return 0 }
        return max(nextReward.daysRequired - (trackingType == "days" ? daysTracked : actionsCompleted), 0)
    }
}
