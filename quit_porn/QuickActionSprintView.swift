import SwiftUI
import UIKit

struct QuickActionSprintView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var streakManager: StreakManager

    @State private var taskChecks: [Bool] = Array(repeating: false, count: 4)
    @State private var didRecordCompletion = false

    private let tasks: [String] = [
        "Stand up and walk for 60 seconds",
        "Drink water",
        "Do 10 bodyweight reps (squats/pushups)",
        "Move your phone away from private space"
    ]

    private var completedCount: Int {
        taskChecks.filter { $0 }.count
    }

    private var allComplete: Bool {
        completedCount == tasks.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.24), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("Action Sprint")
                        .font(.title2.bold())

                    Text("Fast physical actions to break the urge loop.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(value: Double(completedCount), total: Double(tasks.count))
                        .tint(.blue)

                    VStack(spacing: 10) {
                        ForEach(tasks.indices, id: \.self) { index in
                            Button {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                taskChecks[index].toggle()
                                if allComplete, !didRecordCompletion {
                                    didRecordCompletion = true
                                    streakManager.recordCalmExercise()
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: taskChecks[index] ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(taskChecks[index] ? .green : .secondary)
                                    Text(tasks[index])
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    Button(allComplete ? "Great Job - Done" : "Done") {
                        dismiss()
                    }
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .tint(.blue)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Action Sprint")
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
        }
    }
}
