//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation
import SwiftData
import FirebaseAuth

protocol UserOwned: PersistentModel {
    var userId: String { get set }
}

enum ExerciseType: String, Codable {
    case cardio
    case strength
    case mobility
}

typealias FBAuth = FirebaseAuth.Auth

@Model
class UserPrograms: UserOwned {
    var userId: String
    var programs: [WorkoutProgram]
    
    init(userID: String, programs: [WorkoutProgram]) {
        self.userId = userID
        self.programs = programs
    }
}

// Define an Exercise model
@Model
class Exercise: UserOwned {
    @Attribute(.unique) var id: UUID
    var userId: String = ""
    var name: String
    var type: ExerciseType?
    
    init(userId: String = "", name: String, type: ExerciseType = .strength) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.type = type
    }   
}

// Define an ExerciseCategory model
@Model
class ExerciseCategory: UserOwned {
    @Attribute(.unique) var id: UUID
    var userId: String = ""
    var name: String
    var exercises: [Exercise]
    
    init(userId: String = "", name: String, exercises: [Exercise] = []) {
        self.id = UUID() // Automatically generate a unique ID
        self.userId = userId
        self.name = name
        self.exercises = exercises
    }
}

// Define a Session model
@Model
class Session {
    @Attribute(.unique) var id: UUID
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
class WorkoutProgram: UserOwned  {
    @Attribute(.unique) var id: UUID
    var userId: String = ""
    var title: String
    var sessions: [Session]
    var starred: Bool = false

    init (userId: String = "", title: String, sessions: [Session]) {
        self.id = UUID()
        self.userId = userId
        self.title = title
        self.sessions = sessions
        self.starred = false
    }
}

@Model
class SetRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var combined: Int
    var left: Int
    var right: Int
    var reps: Int
    var rest: Int
    
    init(id: UUID, combined: Int, left: Int, right: Int, reps: Int, rest: Int) {
        self.id = id
        self.combined = combined
        self.left = left
        self.right = right
        self.reps = reps
        self.rest = rest
    }
}

@Model
class StrengthEntry: Identifiable {
    @Attribute(.unique) var id: UUID
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
final class WorkoutHistory: UserOwned {
    @Attribute(.unique) var id: UUID
    var userId: String = ""
    var date: Date
    var exercise: String
    var entries: [StrengthEntry]

    init(id: UUID = UUID(), userId: String = "", date: Date = Date(), exercise: String = "", entries: [StrengthEntry] = []) {
        self.id = id
        self.userId = userId
        self.date = date
        self.exercise = exercise
        self.entries = entries
    }
}

