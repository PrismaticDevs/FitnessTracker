//
//  CardioEntry.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
class CardioEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var duration: TimeInterval // In seconds
    var distance: Double?      // Miles/Km
    var calories: Int?
    var note: String?
    var session: CompletedSession?
    
    init(exercise: String, date: Date = Date(), duration: TimeInterval, distance: Double? = nil, calories: Int? = nil, note: String? = nil, session: CompletedSession? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.duration = duration
        self.distance = distance
        self.calories = calories
        self.note = note
        self.session = session
    }
}
