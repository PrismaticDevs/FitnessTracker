//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }
}

@Model
class ExerciseCategory {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var exercises: [Exercise] = []

    init(name: String, exercises: [Exercise] = []) {
        self.name = name
        self.exercises = exercises
    }
}

@Model
class WorkoutEntry {
    @Attribute(.unique) var id: UUID = UUID()
    var exercise: Exercise        // reference to Exercise model
    var date: Date
    var weight: Int
    var left: Int
    var right: Int
    var sets: Int
    var reps: Int
    var rest: Int
    var note: String?

    init(exercise: Exercise, date: Date = Date(), weight: Int = 0, left: Int = 0, right: Int = 0, sets: Int = 3, reps: Int = 8, rest: Int = 60, note: String? = nil) {
        self.exercise = exercise
        self.date = date
        self.weight = weight
        self.left = left
        self.right = right
        self.sets = sets
        self.reps = reps
        self.rest = rest
        self.note = note
    }
}

@Model
class Session {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var exercises: [WorkoutEntry] = []

    init(name: String, exercises: [WorkoutEntry] = []) {
        self.name = name
        self.exercises = exercises
    }
}

@Model
class WorkoutProgram {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var sessions: [Session] = []
    var starred: Bool = false

    init(title: String, sessions: [Session] = [], starred: Bool = false) {
        self.title = title
        self.sessions = sessions
        self.starred = starred
    }
}

@Model
class WorkoutHistory {
    @Attribute(.unique) var id: UUID = UUID()
    var program: WorkoutProgram?   // reference to the program
    var date: Date
    var exercises: [WorkoutEntry] = []
    var note: String?

    init(program: WorkoutProgram? = nil, date: Date = Date(), exercises: [WorkoutEntry] = [], note: String? = nil) {
        self.program = program
        self.date = date
        self.exercises = exercises
        self.note = note
    }
}
