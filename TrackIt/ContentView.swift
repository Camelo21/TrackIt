import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [Milestone]

    @State private var showingNewMilestone = false
    @State private var selectedMilestone: Milestone?
    @State private var showingRewardView = false
    @State private var animateButton = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    if milestones.isEmpty {
                        Text("No milestones yet.")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(milestones) { milestone in
                                    NavigationLink(destination: MilestoneOverviewView(milestone: milestone)) {
                                        milestoneCard(for: milestone)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: milestones)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.title2)
                                .foregroundColor(.black)
                            Text("TrackIt")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingNewMilestone = true }) {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                .scaleEffect(animateButton ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateButton)
                        }
                        .padding()
                        .onAppear {
                            animateButton = true
                        }
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

    private func milestoneCard(for milestone: Milestone) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(milestone.name)
                    .font(.title3)
                    .bold()
                Spacer()
                Text(milestone.trackingType == "days" ? "📆" : "✅")
            }

            if milestone.trackingType == "days" {
                Text("Days in a row: \(milestone.daysTracked)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Completed: \(milestone.actionsCompleted) times")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let nextReward = milestone.nextReward {
                let unit = milestone.trackingType == "days" ? "days" : "actions"
                Text("Next reward in \(milestone.progressUntilNextReward) \(unit)")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            if milestone.trackingType == "count" {
                HStack(spacing: 20) {
                    Button(action: { decrementMilestone(milestone) }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }

                    Button(action: { incrementMilestone(milestone) }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private func incrementMilestone(_ milestone: Milestone) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            if milestones[index].trackingType == "count" {
                milestones[index].actionsCompleted += 1
                milestones[index].actionTimestamps.append(Date())

                // ✅ Detectar si llegó a un reward en modo count
                if let reward = milestones[index].rewardMilestones.first(where: { $0.daysRequired == milestones[index].actionsCompleted }) {
                    NotificationManager.shared.scheduleRewardNotification(for: milestones[index], reward: reward)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowRewardView"), object: milestones[index])
                    }
                }
            } else {
                milestones[index].daysTracked += 1

                // ✅ Detectar si llegó a un reward en modo days
                if let reward = milestones[index].rewardMilestones.first(where: { $0.daysRequired == milestones[index].daysTracked }) {
                    NotificationManager.shared.scheduleRewardNotification(for: milestones[index], reward: reward)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowRewardView"), object: milestones[index])
                    }
                }
            }
        }
    }

    private func decrementMilestone(_ milestone: Milestone) {
        if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
            if milestones[index].trackingType == "count" && milestones[index].actionsCompleted > 0 {
                milestones[index].actionsCompleted -= 1
            }
        }
    }

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
