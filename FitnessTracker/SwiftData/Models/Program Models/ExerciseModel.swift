//
//  Exercise.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

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
