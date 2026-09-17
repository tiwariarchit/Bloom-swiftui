import SwiftUI
import CoreMotion
import UIKit
import Combine

final class MotionResetManager: ObservableObject {
    @Published var shakeCount = 0
    @Published var isRunning = false
    @Published var isComplete = false

    let targetCount = 30

    private let manager = CMMotionManager()
    private var lastShakeTime: Date = .distantPast

    func start() {
        shakeCount = 0
        isComplete = false
        isRunning = true

        guard manager.isAccelerometerAvailable else {
            isRunning = false
            return
        }

        manager.accelerometerUpdateInterval = 0.08
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data, self.isRunning, !self.isComplete else { return }

            let acceleration = data.acceleration
            let magnitude = abs(acceleration.x) + abs(acceleration.y) + abs(acceleration.z)
            let cooldownReady = Date().timeIntervalSince(self.lastShakeTime) > 0.25

            if magnitude > 2.35, cooldownReady {
                self.lastShakeTime = Date()
                self.shakeCount += 1

                if self.shakeCount >= self.targetCount {
                    self.complete()
                }
            }
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        isRunning = false
    }

    private func complete() {
        isComplete = true
        stop()
    }
}

struct MotionResetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var streakManager: StreakManager
    @StateObject private var motion = MotionResetManager()
    @State private var didRecordCompletion = false

    private var progress: Double {
        min(Double(motion.shakeCount) / Double(motion.targetCount), 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.cyan.opacity(0.35), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Text("Motion Reset")
                        .font(.title2.bold())

                    Text("Shake your phone safely to burn off urge energy.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 14)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [.mint, .cyan, .teal]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.25), value: progress)

                        VStack(spacing: 4) {
                            Text("\(motion.shakeCount)/\(motion.targetCount)")
                                .font(.title.bold())
                            Text("resets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 220, height: 220)

                    if motion.isComplete {
                        Label("Great job. Urge cycle interrupted.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.headline)
                    } else {
                        Text("Keep shoulders relaxed. Move from the wrist, not your whole arm.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                    }

                    HStack(spacing: 12) {
                        Button(motion.isRunning ? "Stop" : "Start") {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            motion.isRunning ? motion.stop() : motion.start()
                        }
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                        .tint(motion.isRunning ? .red : .teal)

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
            .onChange(of: motion.isComplete) { _, newValue in
                if newValue {
                    if !didRecordCompletion {
                        didRecordCompletion = true
                        streakManager.recordCalmExercise()
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
            .onDisappear {
                motion.stop()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationTitle("Motion Reset")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
