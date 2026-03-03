//
//  StrengthEntry.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
class StrengthEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var exercise: String
    var date: Date
    var sets: [SetRecord]
    var note: String?
    var session: CompletedSession?
    var iso: Bool = false
    
    init(
        exercise: String,
        date: Date,
        sets: [SetRecord],
        note: String? = nil,
        session: CompletedSession? = nil,
        iso: Bool = false
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.date = date
        self.sets = sets
        self.note = note
        self.session = session
        self.iso = iso
    }
}
