import SwiftUI
import UIKit

struct GroundingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var streakManager: StreakManager

    private let prompts: [String] = [
        "Name 5 things you can see right now.",
        "Name 4 things you can touch.",
        "Name 3 things you can hear.",
        "Name 2 things you can smell.",
        "Name 1 thing you can taste."
    ]

    @State private var stepIndex = 0
    @State private var notes: [String] = Array(repeating: "", count: 5)
    @FocusState private var isInputFocused: Bool
    @State private var didRecordCompletion = false

    private var progress: Double {
        Double(stepIndex) / Double(prompts.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.mint.opacity(0.35), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("5-4-3-2-1 Grounding")
                        .font(.title2.bold())

                    Text("This helps your brain shift away from urges.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(value: progress)
                        .tint(.teal)
                        .padding(.horizontal, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step \(stepIndex + 1)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(prompts[stepIndex])
                            .font(.headline)

                        TextEditor(text: $notes[stepIndex])
                            .frame(minHeight: 130)
                            .padding(8)
                            .background(Color.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .focused($isInputFocused)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    Button(stepIndex == prompts.count - 1 ? "Finish Exercise" : "Next Step") {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if stepIndex < prompts.count - 1 {
                            stepIndex += 1
                        } else {
                            if !didRecordCompletion {
                                didRecordCompletion = true
                                streakManager.recordCalmExercise()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            dismiss()
                        }
                    }
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .tint(.teal)

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputFocused = false
                    }
                }
            }
            .navigationTitle("5-4-3-2-1 Grounding")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
