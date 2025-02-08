//
//  WeightEntry.swift
//  FitnessTracker
//
//  Created by Matt on 2/2/25.
//

import Foundation

struct WeightEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var exercise: String
    let date: Date
    let weight: Int
    let left: Int
    let right: Int
    let note: String
}

