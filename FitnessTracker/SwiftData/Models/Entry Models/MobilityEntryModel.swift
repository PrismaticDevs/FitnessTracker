//
//  MobilityEntry.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
class MobilityEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var holdTime: TimeInterval // How long the stretch was held
    var rounds: Int
    var note: String?
    var session: CompletedSession? = nil

    init(
        exercise: String,
        date: Date = Date(),
        holdTime: TimeInterval = 0,
        rounds: Int = 0,
        note: String? = nil,
        session: CompletedSession? = nil
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.holdTime = holdTime
        self.rounds = rounds
        self.note = note
        self.session = session
    }
}
