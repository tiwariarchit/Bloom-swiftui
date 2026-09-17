import SwiftUI
import Combine

struct TimedProgressRing: View {
    
    @EnvironmentObject var streakManager: StreakManager
    
    let totalDuration: TimeInterval = 24 * 60 * 60   // 24 hours
    
    @AppStorage("streakStartDate")
    private var streakStartTimestamp: Double = Date().timeIntervalSince1970
    
    @State private var currentDate = Date()
    
    // Timer
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var elapsedTime: TimeInterval {
        currentDate.timeIntervalSince(Date(timeIntervalSince1970: streakStartTimestamp))
    }
    
    var progress: Double {
        min(elapsedTime / totalDuration, 1.0)
    }
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            Text(formatTime(elapsedTime))
                .font(.title)
                .bold()
        }
        .frame(width: 250, height: 250)
        .onReceive(timer) { value in
            currentDate = value
            
            // 🔥 24 Hour Completion Logic
            if elapsedTime >= totalDuration {
                
                // Reset start time FIRST (prevents double increment bug)
                streakStartTimestamp = Date().timeIntervalSince1970
                
                // Increase streak
                streakManager.completeExercise()
                
                // Reset current date immediately
                currentDate = Date()
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
