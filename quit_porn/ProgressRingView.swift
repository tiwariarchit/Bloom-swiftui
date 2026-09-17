//
//  ProgressRingView.swift
//  quit_porn
//
//  Created by Archit Kumar  on 23/02/26.
//

import SwiftUI

struct ProgressRingView: View {
    
    var progress: Double
    var timeRemaining: Int
    
    var body: some View {
        
        ZStack {
            
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 12)
            
            // Animated progress
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.mint, .teal, .green]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
                .shadow(color: .green.opacity(0.6), radius: 8)
            
            // Time Text
            VStack(spacing: 6) {
                Text(formatAsMinSec(max(timeRemaining, 0)))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(width: 220, height: 220)
    }

    private func formatAsMinSec(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
