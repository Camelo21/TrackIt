//
//  RewardMilestone.swift
//  TrackIt
//
//  Created by Camilo Melo bernal on 25/03/25.
//

import SwiftData
import SwiftUI

/// **Represents a reward that the user can earn when reaching a milestone.**
@Model
class RewardMilestone: Identifiable {
    var id: UUID // Unique identifier
    var daysRequired: Int  // Days or actions needed to unlock this reward
    var rewardName: String // Reward name (e.g., "New Sneakers")
    var rewardIcon: String // Emoji/icon representing the reward

    /// **Initializes a new reward milestone.**
    init(daysRequired: Int, rewardName: String, rewardIcon: String) {
        self.id = UUID()
        self.daysRequired = daysRequired
        self.rewardName = rewardName
        self.rewardIcon = rewardIcon
    }

    /// **Calculates the exact date when the reward will be received based on the milestone start date.**
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
