//
//  UserPrograms.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
class UserPrograms: UserOwned {
    var userId: String
    var programs: [WorkoutProgram]
    
    init(userID: String, programs: [WorkoutProgram]) {
        self.userId = userID
        self.programs = programs
    }
}
