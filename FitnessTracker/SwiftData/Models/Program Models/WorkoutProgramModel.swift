//
//  Program Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

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
