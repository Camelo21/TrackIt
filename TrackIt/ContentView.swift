import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [Milestone]

    @State private var showingNewMilestone = false

    var body: some View {
        NavigationStack {
            VStack {
                // Show a message if there are no milestones
                if milestones.isEmpty {
                    Text("No milestones yet.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(milestones) { milestone in
                            NavigationLink(destination: Text("Milestone: \(milestone.name)")) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(milestone.name)
                                            .font(.headline)
                                        Spacer()
                                        if let nextReward = milestone.nextReward {
                                            Text(nextReward.rewardIcon)
                                        } else {
                                            Text("🎯") // Safe fallback
                                        }
                                    }
                                    Text("Tracking: \(milestone.daysSinceStart) days")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    if let nextReward = milestone.nextReward {
                                        Text("Next reward in \(max(nextReward.daysRequired - milestone.daysSinceStart, 0)) days: \(nextReward.rewardName)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
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
        }
    }

    /// Deletes a milestone from SwiftData
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

    let previewMilestone = Milestone(name: "Test Milestone", daysTracked: 5)
    container.mainContext.insert(previewMilestone)

    return ContentView()
        .modelContainer(container)
}
