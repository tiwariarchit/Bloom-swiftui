import SwiftUI

struct MeditateView: View {

    // MARK: - State
    @EnvironmentObject var streakManager: StreakManager
    @State private var showKeepAwayMeditation = false
    @State private var showGroundingExercise = false
    @State private var showMotionReset = false
    @State private var showUrgeDelayExercise = false
    @State private var showActionSprintExercise = false
    @State private var selectedDuration = 120
    @State private var selectedPatternIndex = 0
    @State private var scale: CGFloat = 1.0
    @State private var phase: String = "Ready"
    @State private var isRunning = false
    @State private var timeRemaining = 120
    @State private var mainTimer: Timer?

    let calmColor = Color(red: 72/255, green: 209/255, blue: 204/255)

    // MARK: - Breathing Patterns
    let patterns: [BreathingPattern] = [
        BreathingPattern(name: "Box", inhale: 4, hold: 4, exhale: 4, holdAfterExhale: 4),
        BreathingPattern(name: "4-7-8", inhale: 4, hold: 7, exhale: 8, holdAfterExhale: 0),
        BreathingPattern(name: "Quick Calm", inhale: 3, hold: 0, exhale: 3, holdAfterExhale: 0),
        BreathingPattern(name: "Panic Relief", inhale: 5, hold: 0, exhale: 5, holdAfterExhale: 0),
        BreathingPattern(name: "Focus", inhale: 6, hold: 2, exhale: 6, holdAfterExhale: 0)
    ]

    var currentPattern: BreathingPattern {
        patterns[selectedPatternIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        calmColor.opacity(0.6),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        breathingSection
                        distractionSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Calm")
            .fullScreenCover(isPresented: $showKeepAwayMeditation) {
                KeepAwayMeditationScreen()
            }
            .fullScreenCover(isPresented: $showGroundingExercise) {
                GroundingExerciseView()
            }
            .fullScreenCover(isPresented: $showMotionReset) {
                MotionResetView()
            }
            .fullScreenCover(isPresented: $showUrgeDelayExercise) {
                UrgeDelayView()
            }
            .fullScreenCover(isPresented: $showActionSprintExercise) {
                QuickActionSprintView()
            }
            .onDisappear {
                stopBreathing()
            }
        }
    }



    private var breathingSection: some View {
        VStack(spacing: 16) {
            Text("Breathing Reset")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(patterns.indices, id: \.self) { index in
                        Button {
                            selectedPatternIndex = index
                        } label: {
                            Text(patterns[index].name)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    selectedPatternIndex == index
                                    ? calmColor
                                    : Color.white.opacity(0.55)
                                )
                                .foregroundColor(
                                    selectedPatternIndex == index
                                    ? .white
                                    : .primary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .disabled(isRunning)

            Picker("Duration", selection: $selectedDuration) {
                Text("2 min").tag(120)
                Text("5 min").tag(300)
                Text("10 min").tag(600)
            }
            .pickerStyle(.segmented)
            .padding(4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(isRunning)
            .onChange(of: selectedDuration) { _, newValue in
                timeRemaining = newValue
            }

            Text(formatAsMinSec(timeRemaining))
                .font(.title3.monospacedDigit().weight(.medium))
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                calmColor.opacity(0.6),
                                calmColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 1), value: scale)
                    .shadow(color: calmColor.opacity(0.25), radius: 14, x: 0, y: 8)

                VStack(spacing: 6) {
                    Text(phase)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    if isRunning {
                        Text("Keep rhythm with the animation")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(.vertical, 6)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isRunning ? stopBreathing() : startBreathing()
            } label: {
                Text(isRunning ? "Stop Breathing Reset" : "Start Breathing Reset")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isRunning ? Color.red : calmColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var distractionSection: some View {
        VStack(spacing: 12) {
            Text("Urge Distraction Exercises")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            exerciseCard(
                title: "Keep Phone Away",
                subtitle: "Face tracking meditation to force a break from the screen",
                icon: "iphone.and.arrow.forward",
                tint: .teal
            ) {
                showKeepAwayMeditation = true
            }

            exerciseCard(
                title: "5-4-3-2-1 Grounding",
                subtitle: "Redirect attention to senses and interrupt urge spirals",
                icon: "ear.and.waveform",
                tint: .mint
            ) {
                showGroundingExercise = true
            }

            exerciseCard(
                title: "Motion Reset (CoreMotion)",
                subtitle: "Physical movement challenge powered by Apple motion sensors",
                icon: "figure.run",
                tint: .cyan
            ) {
                showMotionReset = true
            }

            exerciseCard(
                title: "Urge Delay (90 sec)",
                subtitle: "Short timed delay with quick prompts to outlast the peak",
                icon: "timer",
                tint: .indigo
            ) {
                showUrgeDelayExercise = true
            }

            exerciseCard(
                title: "Action Sprint",
                subtitle: "Rapid checklist to shift your body and environment",
                icon: "checklist.checked",
                tint: .blue
            ) {
                showActionSprintExercise = true
            }
        }
    }

    private func exerciseCard(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .foregroundStyle(tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Breathing Logic

    private func startBreathing() {
        isRunning = true
        phase = "Inhale"
        timeRemaining = selectedDuration
        scale = 1.0
        mainTimer?.invalidate()
        scheduleNextPhase(startingAt: .inhale, remainingInPhase: currentPattern.inhale)
        startCountdown()
    }

    private func stopBreathing() {
        isRunning = false
        phase = "Ready"
        scale = 1.0
        mainTimer?.invalidate()
        mainTimer = nil
    }

    private func startCountdown() {
        mainTimer?.invalidate()
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isRunning {
                mainTimer?.invalidate()
                mainTimer = nil
                return
            }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopBreathing()
                streakManager.recordCalmExercise()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        RunLoop.main.add(mainTimer!, forMode: .common)
    }

    private enum BreathPhase { case inhale, hold, exhale, holdAfterExhale }

    private func scheduleNextPhase(startingAt phaseToStart: BreathPhase, remainingInPhase: Int) {
        guard isRunning else { return }

        switch phaseToStart {
        case .inhale:
            phase = "Inhale"
            withAnimation(.easeInOut(duration: Double(max(remainingInPhase, 1)))) {
                scale = 1.2
            }
            scheduleTransition(from: .inhale, duration: remainingInPhase)

        case .hold:
            phase = "Hold"
            scheduleTransition(from: .hold, duration: remainingInPhase)

        case .exhale:
            phase = "Exhale"
            withAnimation(.easeInOut(duration: Double(max(remainingInPhase, 1)))) {
                scale = 0.8
            }
            scheduleTransition(from: .exhale, duration: remainingInPhase)

        case .holdAfterExhale:
            phase = "Hold"
            scheduleTransition(from: .holdAfterExhale, duration: remainingInPhase)
        }
    }

    private func scheduleTransition(from current: BreathPhase, duration: Int) {
        guard isRunning else { return }
        let d = max(duration, 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(d)) {
            guard isRunning else { return }
            let p = currentPattern
            switch current {
            case .inhale:
                if p.hold > 0 {
                    scheduleNextPhase(startingAt: .hold, remainingInPhase: p.hold)
                } else {
                    scheduleNextPhase(startingAt: .exhale, remainingInPhase: p.exhale)
                }
            case .hold:
                scheduleNextPhase(startingAt: .exhale, remainingInPhase: p.exhale)
            case .exhale:
                if p.holdAfterExhale > 0 {
                    scheduleNextPhase(startingAt: .holdAfterExhale, remainingInPhase: p.holdAfterExhale)
                } else {
                    scheduleNextPhase(startingAt: .inhale, remainingInPhase: p.inhale)
                }
            case .holdAfterExhale:
                scheduleNextPhase(startingAt: .inhale, remainingInPhase: p.inhale)
            }
        }
    }

    private func formatAsMinSec(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
