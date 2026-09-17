import SwiftUI
import UIKit

struct UrgeDelayView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var streakManager: StreakManager

    @State private var remainingSeconds = 90
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var promptIndex = 0
    @State private var didRecordCompletion = false

    private let prompts = [
        "Take 5 slow breaths through your nose.",
        "Drink a full glass of water.",
        "Name one reason your future matters.",
        "Stand up and stretch your shoulders.",
        "Look away from your phone and relax your jaw."
    ]

    private var progress: Double {
        1 - (Double(remainingSeconds) / 90.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.indigo.opacity(0.25), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Urge Delay")
                        .font(.title2.bold())

                    Text("Delay the impulse for 90 seconds. Peaks usually fade.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    ProgressView(value: progress)
                        .tint(.indigo)

                    Text(formatAsMinSec(remainingSeconds))
                        .font(.system(size: 42, weight: .bold, design: .rounded))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Prompt")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(prompts[promptIndex])
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(spacing: 12) {
                        Button(isRunning ? "Pause" : "Start") {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            isRunning ? pauseTimer() : startTimer()
                        }
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                        .tint(isRunning ? .orange : .indigo)

                        Button("Done") {
                            dismiss()
                        }
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Urge Delay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .onDisappear {
                pauseTimer()
            }
        }
    }

    private func startTimer() {
        guard remainingSeconds > 0 else { return }
        isRunning = true
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds % 15 == 0 {
                    promptIndex = (promptIndex + 1) % prompts.count
                }
            } else {
                pauseTimer()
                if !didRecordCompletion {
                    didRecordCompletion = true
                    streakManager.recordCalmExercise()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func formatAsMinSec(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
