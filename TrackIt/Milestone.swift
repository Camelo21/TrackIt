import SwiftData
import SwiftUI

/// Represents a milestone that a user wants to track.
@Model
class Milestone {
    var name: String       // The name of the milestone (e.g., "Days Without Smoking")
    var startDate: Date    // The date the milestone starts tracking
    var rewardMilestones: [RewardMilestone] // List of rewards at different time milestones
    var daysTracked: Int   // The number of days the user has tracked

    /// Initializes a new milestone with multiple reward milestones.
    init(name: String, startDate: Date = Date(), rewardMilestones: [RewardMilestone] = [], daysTracked: Int = 0) {
        self.name = name
        self.startDate = startDate
        self.rewardMilestones = rewardMilestones
        self.daysTracked = daysTracked
    }

    /// Calculates how many days have passed since the milestone started.
    var daysSinceStart: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }

    /// Finds the next reward that has not yet been reached.
    var nextReward: RewardMilestone? {
        return rewardMilestones
            .filter { $0.daysRequired > daysSinceStart } // Only future rewards
            .sorted { $0.daysRequired < $1.daysRequired } // Sort by closest reward
            .first
    }
}

/// Represents an individual reward milestone.
@Model
class RewardMilestone: Identifiable {
    var id: UUID // Unique identifier for tracking edits
    var daysRequired: Int  // Days needed to unlock this reward
    var rewardName: String // Reward name (e.g., "New Sneakers")
    var rewardIcon: String // Emoji/icon representing the reward

    init(daysRequired: Int, rewardName: String, rewardIcon: String) {
        self.id = UUID()
        self.daysRequired = daysRequired
        self.rewardName = rewardName
        self.rewardIcon = rewardIcon
    }

    /// Calculates the exact date when the reward will be received based on the milestone start date.
    func rewardDate(from startDate: Date) -> String {
        let calendar = Calendar.current
        if let futureDate = calendar.date(byAdding: .day, value: daysRequired, to: startDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: futureDate) // e.g., "March 30, 2025"
        }
        return "Unknown Date"
    }
}
