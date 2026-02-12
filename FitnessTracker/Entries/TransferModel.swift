//
//  TransferModel.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/26.
//

import SwiftUI

struct ExercisePreference: Codable {
    let exerciseName: String
    let setsCount: Int
    let note: String
    let sets: [SetPreference]
    let updatedAt: Date
}

struct SetPreference: Codable {
    let index: Int
    let iso: Bool
    let reps: Int
    let rest: Int
    let weightCombined: Int?
    let weightLeft: Int?
    let weightRight: Int?
}

