import SwiftUI
import AVFoundation
import UIKit

struct KeepAwayMeditationScreen: View {
    private enum BeatOption: String {
        case alpha = "Alpha Beats"
        case theta = "Theta Beats"
        case none = "No Beats"
    }

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var streakManager: StreakManager

    @State private var showTimeSheet = true
    @State private var showBeatPicker = false
    @State private var showCloseEyesAlert = false
    @State private var selectedDuration = 30

    @State private var meditationStarted = false
    @State private var eyesClosed = false
    @State private var countdown = 0
    @State private var isCompleted = false
    @State private var isTimerRunning = false
    @State private var hasChosenBeatForSession = false
    @State private var shouldPromptCloseEyes = false
    @State private var selectedBeat: BeatOption?

    @State private var timer: Timer?
    @State private var soundEffectPlayer: AVAudioPlayer?
    @State private var beatsPlayer: AVAudioPlayer?
    @State private var didRecordCompletion = false

    private var progress: Double {
        guard selectedDuration > 0 else { return 0 }
        let completed = selectedDuration - countdown
        return min(max(Double(completed) / Double(selectedDuration), 0), 1)
    }

    var body: some View {
        ZStack {
            ARKeepAwayView(
                eyesClosed: $eyesClosed,
                headStraight: .constant(true)
            )
            .ignoresSafeArea()

            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Text("Keep Phone Away")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Color.clear.frame(width: 18, height: 18)
                }

                Spacer()

                statusCard

                if meditationStarted && !isCompleted {
                    ProgressRingView(
                        progress: progress,
                        timeRemaining: countdown
                    )
                    .padding(.bottom, 8)
                }

                if isCompleted {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
                    .background(Color.green, in: Capsule())
                    .foregroundColor(.white)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .sheet(isPresented: $showTimeSheet) {
            TimeSelectionSheet(
                selectedDuration: $selectedDuration,
                onStart: {
                    countdown = selectedDuration
                    isCompleted = false
                    meditationStarted = true
                    hasChosenBeatForSession = false
                    shouldPromptCloseEyes = false
                    selectedBeat = nil
                    showTimeSheet = false

                    // Beat must be chosen before asking user to close eyes.
                    showBeatPicker = true
                }
            )
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
        }
        .confirmationDialog(
            "Select Binaural Beat",
            isPresented: $showBeatPicker,
            titleVisibility: .visible
        ) {
            Button(BeatOption.alpha.rawValue) {
                applyBeatSelection(.alpha)
            }
            Button(BeatOption.theta.rawValue) {
                applyBeatSelection(.theta)
            }
            Button(BeatOption.none.rawValue) {
                applyBeatSelection(.none)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose the beat for this keep-away session.")
        }
        .alert("Beat Selected", isPresented: $showCloseEyesAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Now close your eyes to start meditation.")
        }
        .onChange(of: eyesClosed) { _, newValue in
            guard meditationStarted, !isCompleted else { return }
            if newValue {
                if !hasChosenBeatForSession {
                    showBeatPicker = true
                    return
                }
                shouldPromptCloseEyes = false
                startMeditationSession()
            } else {
                stopTimer()
                stopBeats()
            }
        }
        .onDisappear {
            stopTimer()
            stopBeats()
            soundEffectPlayer?.stop()
        }
    }

    private var statusCard: some View {
        VStack(spacing: 8) {
            if isCompleted {
                Label("Meditation Complete", systemImage: "checkmark.circle.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.green)
            } else if !meditationStarted {
                Text("Preparing...")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            } else if hasChosenBeatForSession && shouldPromptCloseEyes && !eyesClosed {
                Text("Beat selected. Close your eyes to begin.")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.yellow)
            } else if eyesClosed {
                Text(isTimerRunning ? "Great, keep your eyes closed" : "Eyes closed. Starting...")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.green)
            } else {
                Text("Close your eyes to continue")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.red)
            }

            if meditationStarted && !isCompleted {
                Text("Timer only runs while eyes stay closed")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let selectedBeat {
                    Text("Beat: \(selectedBeat.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Timer

    private func startMeditationSession() {
        guard meditationStarted, eyesClosed, !isCompleted, timer == nil else { return }
        playStartBeep()
        startSelectedBeat()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        isTimerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard meditationStarted, !isCompleted else {
                    stopTimer()
                    return
                }

                if countdown > 0 {
                    countdown -= 1
                } else {
                    stopTimer()
                    stopBeats()
                    isCompleted = true
                    if !didRecordCompletion {
                        didRecordCompletion = true
                        streakManager.recordCalmExercise()
                    }
                    playCompletionSound()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    private func applyBeatSelection(_ option: BeatOption) {
        selectedBeat = option
        hasChosenBeatForSession = true
        shouldPromptCloseEyes = true
        showCloseEyesAlert = true
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // MARK: - Sounds

    private func playStartBeep() {
        playSoundEffect(named: "start_beep")
    }

    private func playCompletionSound() {
        playSoundEffect(named: "soft_bell")
    }

    private func playSoundEffect(named: String) {
        if let url = Bundle.main.url(forResource: named, withExtension: "mp3") {
            soundEffectPlayer = try? AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.play()
        }
    }

    private func startSelectedBeat() {
        guard let selectedBeat else { return }

        switch selectedBeat {
        case .none:
            stopBeats()
            return
        case .alpha:
            playLoopingBeat(namedCandidates: ["Alpha_beats", "alpha_beats"])
        case .theta:
            playLoopingBeat(namedCandidates: ["Theta", "theta"])
        }
    }

    private func playLoopingBeat(namedCandidates: [String]) {
        stopBeats()

        let url = namedCandidates
            .compactMap { candidate in
                Bundle.main.url(forResource: candidate, withExtension: "mp3")
                ?? Bundle.main.url(forResource: candidate, withExtension: "m4a")
            }
            .first

        guard let url else { return }

        beatsPlayer = try? AVAudioPlayer(contentsOf: url)
        beatsPlayer?.numberOfLoops = -1
        beatsPlayer?.volume = 0.7
        beatsPlayer?.prepareToPlay()
        beatsPlayer?.play()
    }

    private func stopBeats() {
        beatsPlayer?.stop()
        beatsPlayer = nil
    }
}
