//
//  RewardView.Swift.swift
//  TrackIt
//
//  Created by Camilo Melo bernal on 25/03/25.
//

import SwiftUI

struct RewardView: View {
    var milestone: Milestone

    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Congratulations! 🎉")
                .font(.largeTitle)
                .bold()

            Text("You have achieved:")
                .font(.headline)

            Text(milestone.name)
                .font(.title2)
                .bold()

            if let reward = milestone.rewardMilestones.first(where: { $0.daysRequired == milestone.daysTracked }) {
                Text("Reward: \(reward.rewardName) \(reward.rewardIcon)")
                    .font(.title2)
            }

            Text("You've been working hard for \(milestone.daysTracked) days!")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Keep going! More milestones and rewards await. 🚀")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {
                // Dismiss the view
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
