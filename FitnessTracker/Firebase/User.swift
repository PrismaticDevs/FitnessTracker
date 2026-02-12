//
//  User.swift
//  FitnessTracker
//
//  Created by Matt on 2/8/26.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    var display_name: String
    var last_updated: Date?
    var biometrics: Biometrics
    var preferences: Preferences

    struct Biometrics: Codable {
        var age: Int?
        var gender: String?
        var height: Int?
        var weight: Int?
        var created_at: Date?
    }

    struct Preferences: Codable {
        var home_gym: String
        var theme: String
        var units: String
        var hasSettingsUpdate: Bool?
        var hasSocialUpdate: Bool?
    }
}

