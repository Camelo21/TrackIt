import SwiftUI
import SwiftData

/// View for creating a new milestone with name, rewards, and custom intervals.
struct NewMilestoneView: View {
    @Environment(\.modelContext) private var modelContext // Access SwiftData storage

    // State variables for milestone details
    @State private var milestoneName: String = "" // Milestone name
    @State private var rewardMilestones: [RewardMilestone] = [] // List of rewards
    @State private var trackingType: String = "days" // Default tracking mode

    // State for adding rewards
    @State private var newRewardName: String = "" // Temporary reward input
    @State private var selectedIcon: String = "🎁" // Default reward icon
    @State private var rewardDays: Int = 7 // Default: Reward after 7 days

    // Track which reward is being edited
    @State private var editingRewardID: UUID? = nil

    let icons = ["🎁", "🏆", "🎮", "📚", "🏋️‍♂️", "🍕"] // Reward icon options
    @Environment(\.dismiss) private var dismiss // Allows dismissing the view

    var body: some View {
        NavigationStack {
            Form {
                milestoneDetailsSection()
                trackingTypeSection()
                rewardsSection()
                if !rewardMilestones.isEmpty {
                    addedRewardsSection()
                }
            }
            .navigationTitle("New Milestone")
            .toolbar {
                toolbarButtons()
            }
        }
    }

    /// **Milestone Name Input Section**
    private func milestoneDetailsSection() -> some View {
        Section(header: Text("Milestone Details")) {
            TextField("Milestone Name", text: $milestoneName)
        }
    }

    /// **Tracking Type Picker**
    private func trackingTypeSection() -> some View {
        Section(header: Text("Tracking Type")) {
            Picker("Track by", selection: $trackingType) {
                Text("Consecutive Days").tag("days")
                Text("Total Actions").tag("count")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    /// **Rewards Input Section**
    private func rewardsSection() -> some View {
        Section(header: Text("Rewards")) {
            TextField("Reward Name", text: $newRewardName)
            Stepper("\(rewardDays) \(trackingType == "days" ? "days" : "actions")", value: $rewardDays, in: 1...365, step: 1)
            rewardIconPicker()
            addRewardButton()
        }
    }

    /// **Scrollable Reward Icon Picker**
    private func rewardIconPicker() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(icons, id: \.self) { icon in
                    Text(icon)
                        .font(.largeTitle)
                        .padding()
                        .background(selectedIcon == icon ? Color.blue.opacity(0.3) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedIcon = icon
                        }
                }
            }
        }
    }

    /// **Button to Add Reward**
    private func addRewardButton() -> some View {
        Button(action: {
            let newReward = RewardMilestone(daysRequired: rewardDays, rewardName: newRewardName, rewardIcon: selectedIcon)
            rewardMilestones.append(newReward)
            newRewardName = "" // Clear input field
        }) {
            Label("Add Reward", systemImage: "plus")
        }
        .disabled(newRewardName.isEmpty) // Prevent empty rewards
    }

    /// **List of Added Rewards**
    private func addedRewardsSection() -> some View {
        Section(header: Text("Added Rewards")) {
            ForEach(rewardMilestones, id: \.id) { reward in
                rewardRow(for: reward)
            }
            .onDelete { indexSet in
                rewardMilestones.remove(atOffsets: indexSet) // Delete reward
            }
        }
    }

    /// **Single Reward Row**
    private func rewardRow(for reward: RewardMilestone) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(reward.rewardName)
                    .font(.headline)
                Spacer()
                Text("🎯")
            }

            Text("Receive on: \(reward.rewardDate(from: Date()))")
                .foregroundColor(.gray)

            Text("After \(reward.daysRequired) \(trackingType == "days" ? "days" : "actions")")
                .font(.subheadline)
                .foregroundColor(.blue)

            // Edit button to toggle edit mode
            Button(action: {
                if editingRewardID == reward.id {
                    editingRewardID = nil // Stop editing
                } else {
                    editingRewardID = reward.id // Enable editing
                }
            }) {
                Text(editingRewardID == reward.id ? "Done" : "Edit")
                    .foregroundColor(.blue)
            }
            .padding(.top, 5)
        }
    }

    /// **Toolbar Buttons for Save & Cancel**
    private func toolbarButtons() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) { // ✅ Works on macOS & iOS
            Button("Save") {
                let newMilestone = Milestone(name: milestoneName, rewardMilestones: rewardMilestones, trackingType: trackingType)
                modelContext.insert(newMilestone)
                dismiss()
            }
            .disabled(milestoneName.isEmpty)

            Button("Cancel") {
                dismiss()
            }
        }
    }
}

#Preview {
    NewMilestoneView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
