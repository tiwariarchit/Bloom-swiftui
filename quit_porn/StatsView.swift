import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var streakManager: StreakManager
    @State private var chartAnimated = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    weeklySection
                    consistencySection
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [Color.teal.opacity(0.55), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Progress")
            .onAppear {
                chartAnimated = true
            }
        }
    }
}

extension StatsView {
    var summarySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                StatCard(
                    title: "Current Streak",
                    value: "\(streakManager.currentStreak)",
                    subtitle: "Days",
                    icon: "flame.fill",
                    color: .orange
                )
                .frame(width: 150)

                StatCard(
                    title: "Best Streak",
                    value: "\(streakManager.bestStreak)",
                    subtitle: "Days",
                    icon: "trophy.fill",
                    color: .yellow
                )
                .frame(width: 150)

                StatCard(
                    title: "Calm Exercises",
                    value: "\(streakManager.totalCalmExercises)",
                    subtitle: "Total",
                    icon: "figure.mind.and.body",
                    color: .teal
                )
                .frame(width: 150)
            }
            .padding(.horizontal, 2)
        }
    }
}

extension StatsView {
    var weeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Calm Exercises")
                .font(.headline)

            Chart {
                ForEach(Array(streakManager.weeklyCalmExercises.enumerated()), id: \.offset) { index, value in
                    BarMark(
                        x: .value("Day", shortDayName(index)),
                        y: .value("Exercises", chartAnimated ? value : 0)
                    )
                    .foregroundStyle(.teal.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 220)
            .animation(.easeOut(duration: 0.6), value: chartAnimated)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private func shortDayName(_ index: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols[index % 7]
    }
}

extension StatsView {
    var consistencySection: some View {
        let thisWeekExercises = streakManager.weeklyCalmExercises.reduce(0, +)
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        let todayExercises = streakManager.weeklyCalmExercises[todayIndex]
        let relapseDays = streakManager.weeklyRelapse.filter { $0 }.count

        return VStack(spacing: 20) {
            Text("Consistency Overview")
                .font(.headline)

            HStack(spacing: 16) {
                metricBlock(
                    value: "\(thisWeekExercises)",
                    title: "Exercises This Week",
                    color: .green
                )

                metricBlock(
                    value: "\(todayExercises)",
                    title: "Exercises Today",
                    color: .teal
                )

                metricBlock(
                    value: "\(relapseDays)",
                    title: "Relapse Days",
                    color: .red
                )
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private func metricBlock(value: String, title: String, color: Color) -> some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .bold()

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }
}
