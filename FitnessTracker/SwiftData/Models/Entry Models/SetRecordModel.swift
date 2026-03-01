//
//  SetRecord.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation

@Model
class SetRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var combined: Int
    var left: Int
    var right: Int
    var reps: Int
    var rest: Int
    
    init(
        id: UUID = UUID(),
        combined: Int = 0,
        left: Int = 0,
        right: Int = 0,
        reps: Int = 0,
        rest: Int = 0
    ) {
        self.id = id
        self.combined = combined
        self.left = left
        self.right = right
        self.reps = reps
        self.rest = rest
    }
}
