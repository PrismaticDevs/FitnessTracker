//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation

// Define an Exercise model
struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: String
    var reps: String
    var rest: String
}

// Define a Session model
struct Session: Identifiable, Codable {
    let id = UUID()
    var name: String
    var exercises: [Exercise] // Add exercises to the session
}

// Define a WorkoutProgram model
class WorkoutProgram: Identifiable, ObservableObject {
    let id = UUID()
    let title: String
    @Published var sessions: [Session]

    init(title: String, sessions: [Session]) {
        self.title = title
        self.sessions = sessions
    }
}

struct WeightEntry: Codable, Identifiable, Hashable {
    let id = UUID()
    var exercise: String
    var date: Date
    var weight: String
    var left: String
    var right: String
    var sets: String
    var reps: String
    var rest: String
    var note: String
}
