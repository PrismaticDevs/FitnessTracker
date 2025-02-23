//
//  Models.swift
//  FitnessTracker
//
//  Created by Matt on 2/7/25.
//

import Foundation

// Define an Exercise model
struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
}

// Define a Session model
struct Session: Identifiable, Codable {
    var id = UUID()
    var name: String
    var exercises: [Exercise] // Add exercises to the session
}

// Define a WorkoutProgram model
//class WorkoutProgram: Identifiable, ObservableObject {
//    let id = UUID()
//    let title: String
//    @Published var sessions: [Session]
//
//    init(title: String, sessions: [Session]) {
//        self.title = title
//        self.sessions = sessions
//    }
//}

// Define a WorkoutProgram model
class WorkoutProgram: Identifiable, Codable, ObservableObject {
    var id = UUID()
    var title: String
    var isStarred: Bool = false
    @Published var sessions: [Session]

    init(title: String, sessions: [Session]) {
        self.title = title
        self.sessions = sessions
    }

    enum CodingKeys: String, CodingKey {
        case title
        case sessions
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        sessions = try container.decode([Session].self, forKey: .sessions)
        id = UUID() // Generate a new UUID during decoding
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(sessions, forKey: .sessions)
    }
}

struct WeightEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var isStarred: Bool = false
    var exercise: String
    var date: Date
    var weight: String
    var left: String
    var right: String
    var sets: String
    var reps: String
    var rest: String
    var note: String
}
