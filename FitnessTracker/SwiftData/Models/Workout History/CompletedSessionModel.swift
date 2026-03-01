//
//  CompletedSession.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

import Foundation
import SwiftData

@Model
final class CompletedSession {
    // 1. Identity & Metadata
    @Attribute(.unique) var id: UUID
    var date: Date
    var userId: String
    
    // 2. Linking to the Program
    // We store the title as a String so that if a program is renamed or deleted,
    // the historical data remains grouped correctly in your reports.
    var programTitle: String
    var sessionName: String  // e.g., "Leg Day" or "Push A"
    
    // 3. Relationships
    // The @Relationship macro with .cascade means if you delete a session,
    // all the individual entries inside it are deleted too.
    @Relationship(deleteRule: .cascade, inverse: \StrengthEntry.session)
    var strengthEntries: [StrengthEntry] = []
    
    // Future-proofing for the other types we discussed
    @Relationship(deleteRule: .cascade, inverse: \CardioEntry.session)
    var cardioEntries: [CardioEntry] = []
    
    @Relationship(deleteRule: .cascade, inverse: \MobilityEntry.session)
    var mobilityEntries: [MobilityEntry] = []
    
    var note: String

    init(
        id: UUID = UUID(),
        date: Date = .now,
        userId: String = "",
        programTitle: String,
        sessionName: String,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.userId = userId
        self.programTitle = programTitle
        self.sessionName = sessionName
        self.note = note
    }
}
