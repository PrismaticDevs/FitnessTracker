//
//  WorkoutHistory 2.swift
//  FitnessTracker
//
//  Created by Matt on 2/2/25.
//


import Foundation
import Combine

class WorkoutHistory: ObservableObject {
    @Published var history: [WeightEntry] = []

    private var defaults = UserDefaults.standard

    init() {
        loadHistory()
    }

    func loadHistory() {
        if let data = defaults.data(forKey: "WorkoutHistory"),
           let decodedHistory = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            history = decodedHistory
        }
    }

    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: "WorkoutHistory")
        }
    }

    func addEntry(_ entry: WeightEntry) {
        history.append(entry)
        saveHistory()
    }

    func deleteEntry(at index: Int) {
        history.remove(at: index)
        saveHistory()
    }
    
    func maxWeight() -> Int {
            return history.map { $0.weight }.max() ?? 0
        }

        func maxLeftWeight() -> Int {
            return history.map { $0.left }.max() ?? 0
        }

        func maxRightWeight() -> Int {
            return history.map { $0.right }.max() ?? 0
        }
}
