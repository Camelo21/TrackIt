import SwiftUI
import SwiftData

/// View for editing an existing milestone
struct MilestoneDetailView: View {
    @Bindable var milestone: Milestone
    @Environment(\.dismiss) private var dismiss

    // State for editing milestone details
    @State private var milestoneName: String
    @State private var trackingType: String
    @State private var selectedIcon: String
    @State private var rewardMilestones: [RewardMilestone]
    
    @State private var newRewardName: String = ""
    @State private var rewardDays: Int = 7
    @State private var selectedRewardIcon: String = "🎁"
    
    let icons = ["🎯", "🏆", "🎮", "📚", "🏋️‍♂️", "🍕"] // Icon options
    
    init(milestone: Milestone) {
        self.milestone = milestone
        _milestoneName = State(initialValue: milestone.name)
        _trackingType = State(initialValue: milestone.trackingType)
        _selectedIcon = State(initialValue: milestone.trackingType == "days" ? "📆" : "✅")
        _rewardMilestones = State(initialValue: milestone.rewardMilestones)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Edit Milestone Name
                Section(header: Text("Milestone Name")) {
                    TextField("Enter Milestone Name", text: $milestoneName)
                }

                // Select Tracking Type
                Section(header: Text("Tracking Type")) {
                    Picker("Track by", selection: $trackingType) {
                        Text("Consecutive Days").tag("days")
                        Text("Total Actions").tag("count")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Select Milestone Icon
                Section(header: Text("Select Icon")) {
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

                // Rewards Section
                Section(header: Text("Rewards")) {
                    TextField("Reward Name", text: $newRewardName)
                    Stepper("\(rewardDays) \(trackingType == "days" ? "days" : "actions")", value: $rewardDays, in: 1...365, step: 1)
                    
                    // Reward Icon Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(icons, id: \.self) { icon in
                                Text(icon)
                                    .font(.largeTitle)
                                    .padding()
                                    .background(selectedRewardIcon == icon ? Color.blue.opacity(0.3) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedRewardIcon = icon
                                    }
                            }
                        }
                    }

                    // Add Reward Button
                    Button(action: {
                        let newReward = RewardMilestone(daysRequired: rewardDays, rewardName: newRewardName, rewardIcon: selectedRewardIcon)
                        rewardMilestones.append(newReward)
                        newRewardName = "" // Reset input
                    }) {
                        Label("Add Reward", systemImage: "plus")
                    }
                    .disabled(newRewardName.isEmpty)
                }

                // Existing Rewards List
                if !rewardMilestones.isEmpty {
                    Section(header: Text("Existing Rewards")) {
                        ForEach(rewardMilestones, id: \.id) { reward in
                            HStack {
                                Text(reward.rewardName)
                                    .font(.headline)
                                Spacer()
                                Text("\(reward.daysRequired) \(trackingType == "days" ? "days" : "actions")")
                            }
                        }
                        .onDelete { indexSet in
                            rewardMilestones.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Edit Milestone")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(milestoneName.isEmpty)

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    /// **Saves the changes to the milestone**
    private func saveChanges() {
        milestone.name = milestoneName
        milestone.trackingType = trackingType
        milestone.rewardMilestones = rewardMilestones
    }
}

#Preview {
    let container = try! ModelContainer(for: Milestone.self, configurations: .init(isStoredInMemoryOnly: true))

    let previewMilestone = Milestone(name: "Test Milestone", rewardMilestones: [], trackingType: "days", daysTracked: 5)
    container.mainContext.insert(previewMilestone)

    return MilestoneDetailView(milestone: previewMilestone)
        .modelContainer(container)
}//
//  MilestoneDetailView.swift
//  TrackIt
//
//  Created by Camilo Melo bernal on 25/03/25.
//

