//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation

// Define an Exercise model
struct Exercise: Identifiable {
    let id = UUID()
    let name: String
}

// Define a Session model
struct Session: Identifiable {
    let id = UUID()
    let name: String
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
