import SwiftUI
import SwiftData

struct MilestoneOverviewView: View {
    let milestone: Milestone

    var body: some View {
        ZStack {
            // 🎨 Fondo degradado mejorado
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.indigo.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // 📢 Título grande "Overview"
                    Text("Overview")
                        .font(.system(size: 45, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.top)

                    // 🏆 Nombre del milestone
                    Text(milestone.name)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom)

                    // 📆 Info principal
                    mainTrackingInfo()

                    // 🎯 Barra de progreso a próxima recompensa
                    if let nextReward = milestone.nextReward {
                        progressSection(for: nextReward)
                    }

                    Spacer()

                    // ✏️ Botón para ir a editar (Actualizado)
                    NavigationLink(destination: MilestoneDetailView(milestone: milestone)) {
                        Text("Edit Milestone")
                            .foregroundColor(.white)
                            .font(.title3.bold()) // 🎯 Texto más grande
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
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    // MARK: - Subviews

    private func mainTrackingInfo() -> some View {
        VStack(spacing: 12) {
            if milestone.trackingType == "days" {
                Text("Tracked for")
                    .font(.title3)
                    .foregroundColor(.white)
                    .opacity(0.8)

                Text(formattedElapsedTime(from: milestone.startDate))
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            } else {
                Text("Completed Actions:")
                    .font(.title3)
                    .foregroundColor(.white)
                    .opacity(0.8)

                Text("\(milestone.actionsCompleted)")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)

                if milestone.actionTimestamps.isEmpty {
                    Text("No actions yet.")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Action History:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)

                        ForEach(milestone.actionTimestamps, id: \.self) { timestamp in
                            Text(formattedDate(timestamp))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .shadow(radius: 5)
    }

    private func progressSection(for nextReward: RewardMilestone) -> some View {
        let progress = 1.0 - (Double(milestone.progressUntilNextReward) / Double(nextReward.daysRequired))

        return VStack(spacing: 15) {
            Text("Progress to next reward:")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(colorForProgress(progress))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)

            Text("\(Int(progress * 100))% completed")
                .font(.subheadline)
                .foregroundColor(.white)

            Text("\(nextReward.rewardName) \(nextReward.rewardIcon)")
                .font(.title)
                .bold()
                .foregroundColor(.yellow)
                .padding(.top)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .shadow(radius: 5)
    }

    // MARK: - Helpers

    private func formattedElapsedTime(from startDate: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: startDate, to: now)
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        return "\(days)d \(hours)h \(minutes)m"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func colorForProgress(_ progress: Double) -> Color {
        switch progress {
        case 0..<0.5:
            return .gray
        case 0.5..<0.8:
            return .orange
        case 0.8...1.0:
            return .green
        default:
            return .gray
        }
    }
}

#Preview {
    let milestone = Milestone(name: "Sample", trackingType: "days", daysTracked: 3)
    return NavigationStack {
        MilestoneOverviewView(milestone: milestone)
    }
}
