//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation
import SwiftData

// Define an Exercise model
@Model
class Exercise {
    var id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

// Define an ExerciseCategory model
@Model
class ExerciseCategory {
    var id: UUID
    var name: String
    var exercises: [Exercise]
    
    init(name: String, exercises: [Exercise] = []) {
        self.id = UUID() // Automatically generate a unique ID
        self.name = name
        self.exercises = exercises
    }
}

// Define a Session model
@Model
class Session {
    var id: UUID
    var name: String
    var exercises: [Exercise] // Add exercises to the session
    
    init(name: String, exercises: [Exercise]) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
    }
}

// Define a WorkoutProgram model
@Model
class WorkoutProgram  {
    var id: UUID
    var title: String
    var sessions: [Session]
    var starred: Bool = false

    init(title: String, sessions: [Session]) {
        self.id = UUID()
        self.title = title
        self.sessions = sessions
        self.starred = false
    }
}

@Model
class SetRecord: Identifiable {
    var id: UUID
    var combined: Int
    var left: Int
    var right: Int
    var reps: Int
    var note: String?
    
    init(id: UUID, combined: Int, left: Int, right: Int, reps: Int, note: String? = nil) {
        self.id = id
        self.combined = combined
        self.left = left
        self.right = right
        self.reps = reps
        self.note = note
    }
}

@Model
class WorkoutEntry: Identifiable {
    var id: UUID
    var exercise: String
    var date: Date
    var sets: [SetRecord]
    var note: String?
    
    init(exercise: String, date: Date, sets: [SetRecord], note: String? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.sets = sets
        self.note = note
    }
}

@Model
class WorkoutHistory {
    var id: UUID
    var program: String
    var date: Date
    var exercises: [WorkoutEntry] = []
    
    init(program: String, date: Date, note: String) {
        self.id = UUID()
        self.date = date
        self.program = program
        self.exercises = []
    }
}
