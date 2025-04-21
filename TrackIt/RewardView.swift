import SwiftUI

struct RewardView: View {
    var milestone: Milestone

    var body: some View {
        ZStack {
            // 🎨 Fondo épico
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.indigo.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // 🎉 Mensaje principal
                Text("Congratulations!")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .multilineTextAlignment(.center)
                    .padding()

                // 🏆 Nombre del milestone
                Text("You completed:")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))

                Text(milestone.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)

                // 🎁 Mostrar el reward logrado
                if let reward = findAchievedReward() {
                    VStack(spacing: 10) {
                        Text("You've earned:")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(reward.rewardName) \(reward.rewardIcon)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                }

                // 📈 Mostrar progreso
                Text(progressMessage())
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                // 🚀 Mensaje de motivación
                Text("Keep pushing! 🚀 More rewards are waiting for you.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // ✨ Botón cerrar
                Button(action: closeView) {
                    Text("Continue")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 5)
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private func findAchievedReward() -> RewardMilestone? {
        if milestone.trackingType == "days" {
            return milestone.rewardMilestones.first(where: { $0.daysRequired == milestone.daysTracked })
        } else {
            return milestone.rewardMilestones.first(where: { $0.daysRequired == milestone.actionsCompleted })
        }
    }

    private func progressMessage() -> String {
        if milestone.trackingType == "days" {
            return "You've been consistent for \(milestone.daysTracked) days!"
        } else {
            return "You've completed \(milestone.actionsCompleted) actions!"
        }
    }

    private func closeView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

#Preview {
    let milestone = Milestone(
        name: "Test Milestone",
        rewardMilestones: [
            RewardMilestone(daysRequired: 10, rewardName: "Free Coffee", rewardIcon: "☕️")
        ],
        trackingType: "days",
        daysTracked: 10
    )

    RewardView(milestone: milestone)
}
