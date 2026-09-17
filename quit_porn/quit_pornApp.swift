//
//  quit_pornApp.swift
//  quit_porn
//
//  Created by Archit Kumar  on 31/01/26.
//
import SwiftUI
@main
struct BloomApp: App {
    
    @StateObject var streakManager = StreakManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(streakManager)
        }
    }
}
