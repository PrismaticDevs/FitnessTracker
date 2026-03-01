//
//  WorkoutHistory.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
final class WorkoutHistory: UserOwned {
    @Attribute(.unique) var id: UUID
    var userId: String = ""
    var date: Date
    var exercise: String
    var entries: [StrengthEntry]
    var lastUpdated: Date

    init(id: UUID = UUID(), userId: String = "", date: Date = Date(), exercise: String = "", entries: [StrengthEntry] = [], lastUpdated: Date = Date()) {
        self.id = id
        self.userId = userId
        self.date = date
        self.exercise = exercise
        self.entries = entries
        self.lastUpdated = lastUpdated
    }
}
