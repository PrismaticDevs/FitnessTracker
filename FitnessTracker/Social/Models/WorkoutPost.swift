//
//  WorkoutPost.swift
//  FitnessTracker
//
//  A FiT Social post. Stored at `posts/{postId}`. The workout is copied into the
//  post as a snapshot, so posts don't depend on the author's private history
//  being synced, and later edits or deletes of the local session don't change it.
//

import Foundation
import FirebaseFirestore

struct WorkoutPost: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var authorId: String
    var authorUsername: String
    var authorDisplayName: String
    var caption: String
    var workout: WorkoutSnapshot
    @ServerTimestamp var createdAt: Date?
}

struct WorkoutSnapshot: Codable, Equatable {
    var programTitle: String
    var sessionName: String
    var date: Date
    var strength: [StrengthSummary]
    var cardio: [CardioSummary]
    var mobility: [MobilitySummary]

    struct StrengthSummary: Codable, Equatable {
        var exercise: String
        var sets: Int
        var totalReps: Int
        var topWeight: Int   // lb; for single-arm/leg work this is the heavier side
    }

    struct CardioSummary: Codable, Equatable {
        var exercise: String
        var durationSeconds: Int
        var distanceMiles: Double?
    }

    struct MobilitySummary: Codable, Equatable {
        var exercise: String
        var rounds: Int
        var holdSeconds: Int
    }

    var isEmpty: Bool { strength.isEmpty && cardio.isEmpty && mobility.isEmpty }
    var totalSets: Int { strength.reduce(0) { $0 + $1.sets } }
    var totalMiles: Double { cardio.reduce(0) { $0 + ($1.distanceMiles ?? 0) } }
    var totalCardioMinutes: Int { cardio.reduce(0) { $0 + $1.durationSeconds } / 60 }
}

extension WorkoutSnapshot {
    init(session: CompletedSession) {
        programTitle = session.programTitle
        sessionName = session.sessionName
        date = session.date
        strength = session.strengthEntries.map { entry in
            StrengthSummary(
                exercise: entry.exercise,
                sets: entry.sets.count,
                totalReps: entry.sets.reduce(0) { $0 + $1.reps },
                topWeight: entry.sets.map { max($0.combined, $0.left, $0.right) }.max() ?? 0
            )
        }
        cardio = session.cardioEntries.map { entry in
            CardioSummary(
                exercise: entry.exercise,
                durationSeconds: Int(entry.duration),
                distanceMiles: entry.distance
            )
        }
        mobility = session.mobilityEntries.map { entry in
            MobilitySummary(
                exercise: entry.exercise,
                rounds: entry.rounds,
                holdSeconds: Int(entry.holdTime)
            )
        }
    }
}
