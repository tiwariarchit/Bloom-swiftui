//
//  ProgressInsightCard.swift
//  quit_porn
//
//  Created by Archit Kumar  on 16/02/26.
//
import SwiftUI

struct ProgressInsightCard: View {
    
    var currentStreak: Int
    var bestStreak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Insights")
                .font(.headline)

            HStack(spacing: 20) {
                InsightItem(
                    icon: "flame.fill",
                    value: "\(currentStreak)",
                    title: "Current Streak",
                    color: .orange
                )
                
                InsightItem(
                    icon: "trophy.fill",
                    value: "\(bestStreak)",
                    title: "Best Streak",
                    color: .yellow
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct InsightItem: View {
    
    var icon: String
    var value: String
    var title: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
