import SwiftUI
import Combine

class StreakManager: ObservableObject {
    
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("bestStreak") var bestStreak: Int = 0
    
    @AppStorage("weeklyExerciseString") private var weeklyExerciseString: String = ""
    @AppStorage("weeklyRelapseString") private var weeklyRelapseString: String = ""
    @AppStorage("weeklyCalmExerciseString") private var weeklyCalmExerciseString: String = ""
    @AppStorage("totalCalmExercises") var totalCalmExercises: Int = 0
    @AppStorage("statsWeekIdentifier") private var statsWeekIdentifier: String = ""
    
    @Published var weeklyExercises: [Int] = Array(repeating: 0, count: 7)
    @Published var weeklyRelapse: [Bool] = Array(repeating: false, count: 7)
    @Published var weeklyCalmExercises: [Int] = Array(repeating: 0, count: 7)
    
    init() {
        loadData()
        ensureWeekIsCurrent()
    }
    
    // MARK: - Exercise Completed
    
    func completeExercise() {
        ensureWeekIsCurrent()
        let index = todayIndex()
        
        weeklyExercises[index] += 1
        
        if weeklyExercises[index] == 1 && weeklyRelapse[index] == false {
            currentStreak += 1
            
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        }
        
        saveData()
    }
    
    // MARK: - Relapse
    
    func relapse() {
        ensureWeekIsCurrent()
        let index = todayIndex()
        
        currentStreak = 0
        weeklyRelapse[index] = true
        
        saveData()
    }

    // MARK: - Calm Exercises

    func recordCalmExercise() {
        ensureWeekIsCurrent()
        let index = todayIndex()
        weeklyCalmExercises[index] += 1
        totalCalmExercises += 1
        saveData()
    }
    
    // MARK: - Helpers
    
    private func todayIndex() -> Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    private func currentWeekIdentifier() -> String {
        let now = Date()
        let year = Calendar.current.component(.yearForWeekOfYear, from: now)
        let week = Calendar.current.component(.weekOfYear, from: now)
        return "\(year)-W\(week)"
    }

    private func ensureWeekIsCurrent() {
        let weekID = currentWeekIdentifier()
        guard statsWeekIdentifier != weekID else { return }

        if statsWeekIdentifier.isEmpty {
            statsWeekIdentifier = weekID
            saveData()
            return
        }

        statsWeekIdentifier = weekID
        weeklyExercises = Array(repeating: 0, count: 7)
        weeklyRelapse = Array(repeating: false, count: 7)
        weeklyCalmExercises = Array(repeating: 0, count: 7)
        saveData()
    }
    
    private func loadData() {
        if let data = weeklyExerciseString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int].self, from: data),
           decoded.count == 7 {
            weeklyExercises = decoded
        }
        
        if let data = weeklyRelapseString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Bool].self, from: data),
           decoded.count == 7 {
            weeklyRelapse = decoded
        }

        if let data = weeklyCalmExerciseString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int].self, from: data),
           decoded.count == 7 {
            weeklyCalmExercises = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(weeklyExercises),
           let json = String(data: encoded, encoding: .utf8) {
            weeklyExerciseString = json
        }
        
        if let encoded = try? JSONEncoder().encode(weeklyRelapse),
           let json = String(data: encoded, encoding: .utf8) {
            weeklyRelapseString = json
        }

        if let encoded = try? JSONEncoder().encode(weeklyCalmExercises),
           let json = String(data: encoded, encoding: .utf8) {
            weeklyCalmExerciseString = json
        }
    }
}
