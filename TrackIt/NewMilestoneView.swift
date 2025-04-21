import SwiftUI
import SwiftData

struct NewMilestoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var milestoneName: String = ""
    @State private var rewardMilestones: [RewardMilestone] = []
    @State private var trackingType: String = "days"

    @State private var newRewardName: String = ""
    @State private var selectedIcon: String = "🎁"
    @State private var rewardDays: Int = 7

    let icons = ["🎁", "🏆", "🎮", "📚", "🏋️", "🍕"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.indigo.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Text("Create New Milestone")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top)

                    Group {
                        customSectionTitle("Milestone Name")
                        customTextField("Enter Milestone Name", text: $milestoneName)
                    }

                    Group {
                        customSectionTitle("Tracking Type")
                        HStack {
                            Spacer()
                            Picker("Track by", selection: $trackingType) {
                                Text("Days").tag("days")
                                Text("Actions").tag("count")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 250)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                            Spacer()
                        }
                    }

                    Group {
                        customSectionTitle("Set Rewards")
                        VStack(spacing: 15) {
                            customTextField("Reward Name", text: $newRewardName)

                            Stepper("\(rewardDays) \(trackingType == "days" ? "days" : "actions")", value: $rewardDays, in: 1...365)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(icons, id: \.self) { icon in
                                        Text(icon)
                                            .font(.largeTitle)
                                            .padding()
                                            .background(selectedIcon == icon ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                                            .onTapGesture { selectedIcon = icon }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Button(action: {
                                let newReward = RewardMilestone(daysRequired: rewardDays, rewardName: newRewardName, rewardIcon: selectedIcon)
                                rewardMilestones.append(newReward)
                                newRewardName = ""
                            }) {
                                Text("Add Reward")
                                    .foregroundColor(.white)
                                    .font(.title3.bold())
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 32)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.indigo.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                            }
                            .disabled(newRewardName.isEmpty)
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    }

                    if !rewardMilestones.isEmpty {
                        customSectionTitle("Added Rewards")
                        VStack(spacing: 10) {
                            ForEach(rewardMilestones, id: \.id) { reward in
                                HStack {
                                    Text("\(reward.rewardIcon) \(reward.rewardName)")
                                    Spacer()
                                    Text("After \(reward.daysRequired) \(trackingType == "days" ? "days" : "actions")")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }

                    HStack(spacing: 20) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(14)
                        }

                        Button(action: {
                            let newMilestone = Milestone(name: milestoneName, rewardMilestones: rewardMilestones, trackingType: trackingType)
                            modelContext.insert(newMilestone)
                            dismiss()
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .background(Color.green)
                                .cornerRadius(14)
                        }
                        .disabled(milestoneName.isEmpty)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    // MARK: - Helper Components

    private func customSectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .foregroundColor(.white)
            .padding(.horizontal)
    }
}

#Preview {
    NewMilestoneView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
