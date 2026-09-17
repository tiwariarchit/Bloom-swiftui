import UIKit
import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasSeenBloomLanding") private var hasSeenBloomLanding = false

    var body: some View {
        Group {
            if hasSeenBloomLanding {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)

                    StatsView()
                        .tabItem {
                            Image(systemName: "waveform.path.ecg")
                            Text("Stats")
                        }
                        .tag(1)

                    MeditateView()
                        .tabItem {
                            Image(systemName: "leaf.fill")
                            Text("Calm")
                        }
                        .tag(2)
                }
            } else {
                BloomLandingView(hasSeenLanding: $hasSeenBloomLanding)
                    .transition(.opacity)
            }
        }
        .tint(Color(red: 0.09, green: 0.54, blue: 0.56))
    }
}

struct HomeView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var streakManager: StreakManager

    @State private var showPanicMode = false
    @AppStorage("streakStartDate") private var streakStartTimestamp: Double = 0
    @State private var currentDate = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let totalDuration: TimeInterval = 24 * 60 * 60

    private var validStartDate: Date {
        guard streakStartTimestamp > 0 else { return currentDate }
        return Date(timeIntervalSince1970: streakStartTimestamp)
    }

    private var elapsedTime: TimeInterval {
        max(currentDate.timeIntervalSince(validStartDate), 0)
    }

    private var progress: Double {
        min(elapsedTime / totalDuration, 1)
    }

    private var remainingTime: TimeInterval {
        max(totalDuration - elapsedTime, 0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.teal.opacity(0.55),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        streakSection
                        panicButton

                        ProgressInsightCard(
                            currentStreak: streakManager.currentStreak,
                            bestStreak: streakManager.bestStreak
                        )

                        educationSection
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 0)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Home")
            .onAppear {
                currentDate = Date()
                if streakStartTimestamp <= 0 {
                    streakStartTimestamp = currentDate.timeIntervalSince1970
                }
            }
            .onReceive(timer) { value in
                currentDate = value

                if streakStartTimestamp <= 0 {
                    streakStartTimestamp = value.timeIntervalSince1970
                    return
                }

                if elapsedTime >= totalDuration {
                    streakManager.completeExercise()
                    streakStartTimestamp = value.timeIntervalSince1970
                    currentDate = value
                }
            }
            .sheet(isPresented: $showPanicMode) {
                PanicSheetView(
                    selectedTab: $selectedTab,
                    onRelapseConfirmed: {
                        streakStartTimestamp = Date().timeIntervalSince1970
                        currentDate = Date()
                        streakManager.relapse()
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .center) {
            Text(currentDate.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(streakManager.currentStreak) day streak")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var streakSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.mint, .teal, .green]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: progress)

                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.title.bold())
                    Text("complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 230, height: 230)
            .frame(maxWidth: .infinity)

            VStack(spacing: 6) {
                Text("Next streak increment in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(formatTime(remainingTime))
                    .font(.title3.bold())
                Text("Stay consistent for the next 24h window.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            ProgressView(value: progress)
                .tint(.teal)
                .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }

    private var panicButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            showPanicMode = true
        } label: {
            Label("Panic Button", systemImage: "exclamationmark.triangle.fill")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: 240)
                .frame(minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .tint(.red)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension HomeView {
    private var educationItems: [(icon: String, title: String, description: String)] {
        [
            ("brain.head.profile", "Brain Fog", "Reduces clarity, focus, and decision making."),
            ("bolt.slash", "Low Motivation", "Artificial dopamine spikes weaken discipline."),
            ("heart.slash", "Relationship Damage", "Impacts emotional connection and intimacy."),
            ("chart.line.downtrend.xyaxis", "Productivity Drop", "Long-term goals quietly suffer."),
            ("eye.slash", "Desensitization", "Normal pleasures feel less satisfying over time."),
            ("person.crop.circle.badge.xmark", "Isolation", "Creates social withdrawal and reduced confidence."),
            ("clock.arrow.circlepath", "Time Loss", "Hours disappear without meaningful growth."),
            ("exclamationmark.triangle", "Impulse Weakness", "Self-control gets weaker with repetition.")
        ]
    }

    var educationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why Staying Clean Matters")
                .font(.headline)

            LazyVStack(spacing: 14) {
                ForEach(educationItems, id: \.title) { item in
                    EducationCard(
                        icon: item.icon,
                        title: item.title,
                        description: item.description
                    )
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct EducationCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.2), Color.red.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
#Preview {
    ContentView()
}
