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
    var isCompleted: Bool = false
    
    init(userId: String = "", name: String, type: ExerciseType = .strength) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.type = type
        self.isCompleted = isCompleted
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

// Define a model for all completed sessions in a program
@Model
class CompletedSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var programTitle: String
    var sessionName: String
    
    // Relationships for the new data types
    @Relationship(deleteRule: .cascade) var strengthEntries: [StrengthEntry] = []
    @Relationship(deleteRule: .cascade) var mobilityEntries: [MobilityEntry] = []
    @Relationship(deleteRule: .cascade) var cardioEntries: [CardioEntry] = []
    // Optional: Link to the original template if needed
    var templateId: UUID?

    init(id: UUID = UUID(), date: Date = .now, programTitle: String, sessionName: String) {
        self.id = id
        self.date = date
        self.programTitle = programTitle
        self.sessionName = sessionName
    }
}

// Define a model for Program Reports
@Model
class ProgramReport: Identifiable {
    @Attribute(.unique) var id: UUID
    var programName: String
    var startDate: Date
    var endDate: Date
    // Overall Stats
    var totalSessions: Int
    // Strength Stats
    var totalSets: Int
    var totalReps: Int
    var totalWeight: Int
    // Cardio Stats
    var totalCardioDuration: TimeInterval
    var totalDistance: Double
    // Mobility Stats
    var totalMobiltyHoldTime: TimeInterval
    var totalMobilttyRounds: Int
    
    init(id: UUID, programName: String, startDate: Date, endDate: Date, totalSessions: Int, totalSets: Int, totalReps: Int, totalWeight: Int, totalCardioDuration: TimeInterval, totalDistance: Double, totalMobiltyHoldTime: TimeInterval, totalMobilttyRounds: Int) {
        self.id = id
        self.programName = programName
        self.startDate = startDate
        self.endDate = endDate
        self.totalSessions = totalSessions
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.totalCardioDuration = totalCardioDuration
        self.totalDistance = totalDistance
        self.totalMobiltyHoldTime = totalMobiltyHoldTime
        self.totalMobilttyRounds = totalMobilttyRounds
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

// MARK: Entry Types
@Model
class StrengthEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var sets: [SetRecord]
    var note: String?
    var programTitle: String?
    
    init(exercise: String, date: Date, sets: [SetRecord], note: String? = nil, programTitle: String) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.sets = sets
        self.note = note
        self.programTitle = programTitle
    }
}

@Model
class CardioEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var duration: TimeInterval // In seconds
    var distance: Double?      // Miles/Km
    var elevation: Double?     // Added for your elevation input
    var heartRate: Int?       // Added for your heart rate input
    var calories: Int?
    var note: String?
    
    init(
        exercise: String,
        date: Date = Date(),
        duration: TimeInterval,
        distance: Double? = nil,
        elevation: Double? = nil,
        heartRate: Int? = nil,
        calories: Int? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.duration = duration
        self.distance = distance
        self.elevation = elevation
        self.heartRate = heartRate
        self.calories = calories
        self.note = note
    }
}

@Model
class MobilityEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var holdTime: TimeInterval // How long the stretch was held
    var rounds: Int
    var note: String?

    init(exercise: String, date: Date = Date(), holdTime: TimeInterval, rounds: Int, note: String? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.holdTime = holdTime
        self.rounds = rounds
        self.note = note
    }
}

