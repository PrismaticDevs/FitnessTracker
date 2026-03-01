//
//  ExerciseCategory.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

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
