import SwiftUI
import SwiftData

/// View for creating a new milestone with name, rewards, and custom intervals.
struct NewMilestoneView: View {
    @Environment(\.modelContext) private var modelContext // Access SwiftData storage

    // State variables for milestone details
    @State private var milestoneName: String = "" // Milestone name
    @State private var rewardMilestones: [RewardMilestone] = [] // List of rewards

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
                // Section for entering milestone name
                Section(header: Text("Milestone Details")) {
                    TextField("Milestone Name", text: $milestoneName)
                }

                // Section for adding rewards
                Section(header: Text("Rewards")) {
                    TextField("Reward Name", text: $newRewardName)

                    Stepper("\(rewardDays) days", value: $rewardDays, in: 1...365, step: 1)

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

                    // Button to add a new reward
                    Button(action: {
                        let newReward = RewardMilestone(daysRequired: rewardDays, rewardName: newRewardName, rewardIcon: selectedIcon)
                        rewardMilestones.append(newReward)
                        newRewardName = "" // Clear input field
                    }) {
                        Label("Add Reward", systemImage: "plus")
                    }
                    .disabled(newRewardName.isEmpty) // Prevent empty rewards
                }

                // List of added rewards with edit & delete options
                if !rewardMilestones.isEmpty {
                    Section(header: Text("Added Rewards")) {
                        ForEach(rewardMilestones, id: \.id) { reward in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(reward.rewardName)
                                        .font(.headline)
                                    Spacer()
                                    Text("🎯")
                                }

                                Text("Receive on: \(reward.rewardDate(from: Date()))")
                                    .foregroundColor(.gray)

                                Text("After \(reward.daysRequired) days")
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

                                // Only show editing fields when user taps "Edit"
                                if editingRewardID == reward.id {
                                    TextField("Edit Name", text: Binding(
                                        get: { reward.rewardName },
                                        set: { newValue in
                                            if let index = rewardMilestones.firstIndex(where: { $0.id == reward.id }) {
                                                rewardMilestones[index].rewardName = newValue
                                            }
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Stepper("Days: \(reward.daysRequired)", value: Binding(
                                        get: { reward.daysRequired },
                                        set: { newValue in
                                            if let index = rewardMilestones.firstIndex(where: { $0.id == reward.id }) {
                                                rewardMilestones[index].daysRequired = newValue
                                            }
                                        }
                                    ), in: 1...365, step: 1)

                                    Menu {
                                        ForEach(icons, id: \.self) { icon in
                                            Button(action: {
                                                if let index = rewardMilestones.firstIndex(where: { $0.id == reward.id }) {
                                                    rewardMilestones[index].rewardIcon = icon
                                                }
                                            }) {
                                                Text(icon)
                                            }
                                        }
                                    } label: {
                                        Text(reward.rewardIcon)
                                            .font(.largeTitle)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            rewardMilestones.remove(atOffsets: indexSet) // Delete reward
                        }
                    }
                }
            }
            .navigationTitle("New Milestone")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newMilestone = Milestone(name: milestoneName, rewardMilestones: rewardMilestones)
                        modelContext.insert(newMilestone)
                        dismiss()
                    }
                    .disabled(milestoneName.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewMilestoneView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
