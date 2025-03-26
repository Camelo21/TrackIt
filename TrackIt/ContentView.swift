import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [Milestone]

    @State private var showingNewMilestone = false
    @State private var selectedMilestone: Milestone?
    @State private var showingRewardView = false

    var body: some View {
        NavigationStack {
            VStack {
                if milestones.isEmpty {
                    Text("No milestones yet.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(milestones) { milestone in
                            NavigationLink(destination: MilestoneDetailView(milestone: milestone)) {
                                milestoneRow(for: milestone)
                            }
                        }
                        .onDelete(perform: deleteMilestone)
                    }
                }
                
                // ✅ Test Buttons
                HStack {
                    Button("Test Notification") {
                        let testMilestone = Milestone(name: "Test Milestone")
                        let testReward = RewardMilestone(daysRequired: 3, rewardName: "Free Coffee", rewardIcon: "☕️")

                        // ✅ Schedule notification with a delay (10 seconds)
                        NotificationManager.shared.scheduleRewardNotification(for: testMilestone, reward: testReward, delay: 10)
                    }

                    Button("Add Day to First Milestone") {
                        if let firstMilestone = milestones.first {
                            incrementMilestone(firstMilestone)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("TrackIt")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingNewMilestone = true }) {
                        Label("Add Milestone", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewMilestone) {
                NewMilestoneView()
            }
            .sheet(isPresented: $showingRewardView) {
                if let milestone = selectedMilestone {
                    RewardView(milestone: milestone)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowRewardView"))) { notification in
                if let milestone = notification.object as? Milestone {
                    selectedMilestone = milestone
                    showingRewardView = true
                }
            }
        }
    }

    /// **Displays a single milestone row**
    private func milestoneRow(for milestone: Milestone) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(milestone.name)
                    .font(.headline)
                Spacer()
                Text(milestone.trackingType == "days" ? "📆" : "✅")
            }

            if milestone.trackingType == "days" {
                Text("Days in a row: \(milestone.daysTracked)")
            } else {
                Text("Completed: \(milestone.actionsCompleted) times")
            }

            if let nextReward = milestone.nextReward {
                let unit = milestone.trackingType == "days" ? "days" : "actions"
                Text("Next reward in \(milestone.progressUntilNextReward) \(unit)")
                    .foregroundColor(.blue)
            }

            if milestone.trackingType == "count" {
                HStack {
                    Button(action: { decrementMilestone(milestone) }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    Button(action: { incrementMilestone(milestone) }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }

    /// **Increments milestone progress (for both tracking types)**
    private func incrementMilestone(_ milestone: Milestone) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            if milestones[index].trackingType == "count" {
                milestones[index].actionsCompleted += 1
            } else {
                // ✅ Update days tracked and check for streak reset
                milestones[index].updateDaysTracked()
                milestones[index].daysTracked += 1

                // ✅ Check if the user reached a reward milestone
                if let reward = milestones[index].rewardMilestones.first(where: { $0.daysRequired == milestones[index].daysTracked }) {
                    NotificationManager.shared.scheduleRewardNotification(for: milestones[index], reward: reward)
                    
                    // ✅ Trigger the reward view immediately
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowRewardView"), object: milestones[index])
                    }
                }
            }
        }
    }

    /// **Decrements milestone progress (only for count-based tracking)**
    private func decrementMilestone(_ milestone: Milestone) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            if milestones[index].trackingType == "count" && milestones[index].actionsCompleted > 0 {
                milestones[index].actionsCompleted -= 1
            }
        }
    }

    /// **Deletes a milestone from SwiftData**
    private func deleteMilestone(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(milestones[index])
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Milestone.self, configurations: .init(isStoredInMemoryOnly: true))

    let previewMilestone = Milestone(name: "Test Milestone", rewardMilestones: [], trackingType: "days", daysTracked: 5)
    container.mainContext.insert(previewMilestone)

    return ContentView()
        .modelContainer(container)
}
